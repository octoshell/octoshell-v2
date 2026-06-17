#!/usr/bin/env ruby
# frozen_string_literal: true

# Скрипт для подсчёта узлочасов и количества задач по кварталам
# с группировкой по логинам, проектам или организациям.
# Сравнивает данные из sacct (SSH) и из БД jobstat_jobs.
#
# Использование:
#   bundle exec ruby scripts/cluster_stats_quarterly.rb <cluster_id> <jobstat_cluster> <start_date> <end_date> <group_by>
#
# Пример:
#   bundle exec ruby scripts/cluster_stats_quarterly.rb 1 lomonosov-2 2025-01-01 2025-12-31 project
#
# group_by: login | project | organization

require_relative '../config/environment'

SACCT_PATH = '/usr/octo/sacct'
HOUR_SEC = 3600
DAY_SEC = HOUR_SEC * 24

# ===== Парсинг аргументов =====

cluster_id = ARGV[0].to_i
jobstat_cluster = ARGV[1]
start_date = Date.parse(ARGV[2])
end_date = Date.parse(ARGV[3])
group_by = ARGV[4] || 'login'

unless %w[login project organization].include?(group_by)
  raise "Invalid group_by: #{group_by}. Must be login, project, or organization."
end

cluster = Core::Cluster.find(cluster_id)
puts "Cluster: #{cluster.name_ru}"
puts "Period: #{start_date} - #{end_date}"
puts "Group by: #{group_by}"
puts

# ===== Генерация кварталов =====

def generate_quarters(start_date, end_date)
  quarters = []
  current = start_date.beginning_of_quarter
  while current <= end_date
    q_end = current.end_of_quarter
    q_label = "Q#{(current.month / 3.0).ceil} #{current.year}"
    quarters << [current, q_end, q_label]
    current = q_end + 1.day
  end
  quarters
end

quarters = generate_quarters(start_date, end_date)
puts "Quarters: #{quarters.map(&:last).join(', ')}"
puts

# ===== Распределение задания по кварталам =====

def distribute_to_quarters(start_time, end_time, quarters)
  result = []
  total_seconds = (end_time - start_time).to_f
  return result if total_seconds <= 0

  quarters.each do |q_start, q_end, q_label|
    overlap_start = [start_time, q_start.beginning_of_day].max
    overlap_end = [end_time, q_end.end_of_day].min
    next unless overlap_end > overlap_start

    overlap_seconds = (overlap_end - overlap_start).to_f
    fraction = overlap_seconds / total_seconds
    result << [q_label, fraction]
  end
  result
end

# ===== Парсинг elapsed в секунды =====

def parse_elapsed_to_seconds(elapsed_str)
  seconds = 0
  if elapsed_str.include?('-')
    days, rest = elapsed_str.split('-')
    seconds += days.to_i * DAY_SEC
    elapsed_str = rest
  end
  time_parts = elapsed_str.split(':').map(&:to_i)
  case time_parts.size
  when 3
    seconds += time_parts[0] * HOUR_SEC + time_parts[1] * 60 + time_parts[2]
  when 2
    seconds += time_parts[0] * 60 + time_parts[1]
  else
    return nil
  end
  seconds
end

# ===== Сбор данных из sacct =====

puts 'Fetching data from sacct...'
sacct_command = "sudo #{SACCT_PATH} -X " \
                '--format=User,JobID,NNodes,Elapsed,Start,End,State,Partition ' \
                '--noheader --parsable2 ' \
                "-S #{start_date.strftime('%Y-%m-%d')} -E #{(end_date + 1.day).strftime('%Y-%m-%d')}"

stdout, stderr = cluster.execute(sacct_command)
puts sacct_command
puts stdout[0..10]
raise "sacct error: #{stderr}" if stderr.present?

# Структура: { login => { quarter => { partition => { node_hours: X, job_count: N } } } }
sacct_data = Hash.new do |h, login|
  h[login] = Hash.new do |h2, quarter|
    h2[quarter] = Hash.new { |h3, part| h3[part] = { node_hours: 0.0, job_count: 0 } }
  end
end

sacct_logins = Set.new
sacct_partitions = Set.new
# { quarter_label => Set[login] } — уникальные логины, запустившиеся в каждом квартале
sacct_logins_per_quarter = Hash.new { |h, k| h[k] = Set.new }

stdout.each_line do |line|
  line.chomp!
  fields = line.split('|')
  next if fields.size < 8

  user, jobid, nnodes_str, elapsed_str, start_str, end_str, state, partition = fields

  # Пропускаем дочерние задания
  next if jobid.include?('.')

  # Пропускаем отмененные с нулевым временем
  next if state.include?('CANCELLED') && elapsed_str == '00:00:00'

  nnodes = nnodes_str.to_i
  next if nnodes <= 0

  elapsed_seconds = parse_elapsed_to_seconds(elapsed_str)
  next if elapsed_seconds.nil? || elapsed_seconds <= 0

  start_time = Time.zone.parse(start_str)
  end_time = Time.zone.parse(end_str)
  next if start_time.nil? || end_time.nil?

  part_name = partition.presence || 'unknown'
  sacct_logins << user
  sacct_partitions << part_name

  node_hours = (elapsed_seconds.to_f / HOUR_SEC) * nnodes
  quarter_fractions = distribute_to_quarters(start_time, end_time, quarters)

  quarter_fractions.each do |q_label, fraction|
    sacct_data[user][q_label][part_name][:node_hours] += node_hours * fraction
    sacct_data[user][q_label][part_name][:job_count] += 1
    sacct_logins_per_quarter[q_label] << user
  end
end

puts "sacct: #{sacct_logins.size} logins, #{sacct_partitions.size} partitions"

# ===== Сбор данных из БД (SQL-группировка) =====

puts 'Fetching data from jobstat_jobs (SQL grouping)...'

# Строим CASE-выражения для каждого квартала
quarter_selects = []
quarters.each_with_index do |(q_start, q_end, q_label), idx|
  q_start_str = q_start.beginning_of_day.strftime('%Y-%m-%d %H:%M:%S')
  q_end_str = q_end.end_of_day.strftime('%Y-%m-%d %H:%M:%S')

  # overlap_start = GREATEST(start_time, quarter_start)
  # overlap_end = LEAST(end_time, quarter_end)
  # Если overlap_end > overlap_start, то задание пересекает этот квартал
  # node_hours_in_quarter = EXTRACT(EPOCH FROM overlap) / 3600 * num_nodes
  quarter_selects << <<~SQL.squish
    SUM(CASE
      WHEN GREATEST(start_time, TIMESTAMP '#{q_start_str}') < LEAST(end_time, TIMESTAMP '#{q_end_str}')
      THEN EXTRACT(EPOCH FROM LEAST(end_time, TIMESTAMP '#{q_end_str}') - GREATEST(start_time, TIMESTAMP '#{q_start_str}')) / 3600.0 * num_nodes
      ELSE 0
    END) AS q#{idx}_nh,
    SUM(CASE
      WHEN GREATEST(start_time, TIMESTAMP '#{q_start_str}') < LEAST(end_time, TIMESTAMP '#{q_end_str}')
      THEN 1
      ELSE 0
    END) AS q#{idx}_jc
  SQL
end

select_clause = "login, COALESCE(NULLIF(partition, ''), 'unknown') AS partition, #{quarter_selects.join(', ')}"

# Базовый запрос для всех логинов (Лист 2)
base_scope = Jobstat::Job.where(cluster: jobstat_cluster)
                         .where('start_time < ? AND end_time > ?', end_date + 1.day, start_date)
                         .where('num_nodes > 0')
                         .where('end_time > start_time')

# Запрос для Листа 2: все логины
all_db_rows = base_scope.group("login, COALESCE(NULLIF(partition, ''), 'unknown')")
                        .select(select_clause)

db_data = Hash.new do |h, login|
  h[login] = Hash.new do |h2, quarter|
    h2[quarter] = Hash.new { |h3, part| h3[part] = { node_hours: 0.0, job_count: 0 } }
  end
end

db_logins = Set.new
db_partitions = Set.new
# { quarter_label => Set[login] } — уникальные логины, запустившиеся в каждом квартале
db_logins_per_quarter = Hash.new { |h, k| h[k] = Set.new }

all_db_rows.each do |row|
  login = row.login
  next if login.blank?

  part_name = row.partition.presence || 'unknown'
  db_logins << login
  db_partitions << part_name

  quarters.each_with_index do |(_, _, q_label), idx|
    nh = row.public_send("q#{idx}_nh").to_f
    jc = row.public_send("q#{idx}_jc").to_i
    next if nh == 0 && jc == 0

    db_data[login][q_label][part_name][:node_hours] = nh
    db_data[login][q_label][part_name][:job_count] = jc
    db_logins_per_quarter[q_label] << login
  end
end

puts "DB: #{db_logins.size} logins, #{db_partitions.size} partitions"
puts

# ===== Группировка =====

# Определяем маппинг login -> group_key и group_key -> group_id
def build_login_group_map(logins, group_by)
  login_to_group = {}
  group_to_id = {}

  return [logins.each_with_object({}) { |l, h| h[l] = l }, {}] if group_by == 'login'

  # Для project/organization ищем в Core::Member
  members = Core::Member.where(login: logins.to_a).includes(project: :organization)

  members.each do |member|
    project = member.project
    next unless project

    case group_by
    when 'project'
      group_name = project.title
      login_to_group[member.login] = group_name
      group_to_id[group_name] = project.id
    when 'organization'
      org = project.organization
      next unless org

      group_name = org.name
      login_to_group[member.login] = group_name
      group_to_id[group_name] = org.id
    end
  end

  # Логины без привязки
  logins.each do |login|
    login_to_group[login] ||= login
  end

  [login_to_group, group_to_id]
end

sacct_login_map, sacct_group_ids = build_login_group_map(sacct_logins, group_by)
db_login_map, db_group_ids = build_login_group_map(db_logins, group_by)
all_group_ids = sacct_group_ids.merge(db_group_ids)

# ===== Агрегация по группам =====

def aggregate_by_group(data, login_map, group_by)
  result = Hash.new do |h, group|
    h[group] = Hash.new do |h2, quarter|
      h2[quarter] = Hash.new { |h3, part| h3[part] = { node_hours: 0.0, job_count: 0 } }
    end
  end

  data.each do |login, quarters_data|
    group_key = login_map[login]

    # Для project/organization пропускаем логины без привязки на листе 1
    if group_by != 'login' && group_key == login
      # Логин не привязан к проекту/организации, пропускаем для листа 1
      next
    end

    quarters_data.each do |quarter, partitions_data|
      partitions_data.each do |partition, values|
        result[group_key][quarter][partition][:node_hours] += values[:node_hours]
        result[group_key][quarter][partition][:job_count] += values[:job_count]
      end
    end
  end

  result
end

# Для листа 1: только группы (проекты/организации), без одиночных логинов
sheet1_sacct = aggregate_by_group(sacct_data, sacct_login_map, group_by)
sheet1_db = aggregate_by_group(db_data, db_login_map, group_by)

# Для листа 2: все логины
sheet2_sacct = sacct_data
sheet2_db = db_data

# ===== Сбор логинов по группам =====

def collect_logins_by_group(data, login_map, group_by)
  result = Hash.new { |h, k| h[k] = Set.new }
  data.each do |login, _|
    group_key = login_map[login]
    next if group_by != 'login' && group_key == login

    result[group_key] << login
  end
  result
end

sacct_logins_by_group = collect_logins_by_group(sacct_data, sacct_login_map, group_by)
db_logins_by_group = collect_logins_by_group(db_data, db_login_map, group_by)

# ===== Подсчёт уникальных логинов по группам и кварталам =====

# { group => { quarter => Set[login] } }
def collect_logins_by_group_and_quarter(data, login_map, group_by)
  result = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Set.new } }
  data.each do |login, quarters_data|
    group_key = login_map[login]
    next if group_by != 'login' && group_key == login

    quarters_data.each do |quarter, partitions_data|
      has_data = partitions_data.any? { |_, v| v[:job_count] > 0 }
      result[group_key][quarter] << login if has_data
    end
  end
  result
end

sacct_logins_by_group_quarter = collect_logins_by_group_and_quarter(sacct_data, sacct_login_map, group_by)
db_logins_by_group_quarter = collect_logins_by_group_and_quarter(db_data, db_login_map, group_by)

# ===== Подсчёт уникальных логинов по группам за весь период =====

# { group => Set[login] } — логины, запустившие хотя бы одну задачу за весь период
def collect_logins_by_group_total(data, login_map, group_by)
  result = Hash.new { |h, k| h[k] = Set.new }
  data.each do |login, quarters_data|
    group_key = login_map[login]
    next if group_by != 'login' && group_key == login

    has_any_data = quarters_data.any? do |_, partitions_data|
      partitions_data.any? { |_, v| v[:job_count] > 0 }
    end
    result[group_key] << login if has_any_data
  end
  result
end

sacct_logins_by_group_total = collect_logins_by_group_total(sacct_data, sacct_login_map, group_by)
db_logins_by_group_total = collect_logins_by_group_total(db_data, db_login_map, group_by)

all_groups = (sheet1_sacct.keys + sheet1_db.keys).uniq.sort
all_partitions = (sacct_partitions + db_partitions).to_a.sort

# ===== Генерация XLSX =====

require 'write_xlsx'
require 'stringio'

buffer = StringIO.new
workbook = WriteXLSX.new(buffer)

# Форматы
header_fmt = workbook.add_format(
  bold: true, align: 'center', valign: 'vcenter',
  text_wrap: true, border: 1, bg_color: '#D9E1F2'
)
total_fmt = workbook.add_format(bold: true, border: 1)
cell_fmt = workbook.add_format(align: 'left', valign: 'vcenter', border: 1)
number_fmt = workbook.add_format(align: 'right', valign: 'vcenter', border: 1, num_format: '#,##0.00')
integer_fmt = workbook.add_format(align: 'right', valign: 'vcenter', border: 1, num_format: '#,##0')

# ===== Лист 1: Сводная =====
ws1 = workbook.add_worksheet('Сводная')

headers1 = ['ID', 'Группа', 'Квартал', 'Раздел', 'sacct узлочасы', 'sacct задач', 'sacct логинов', 'db узлочасы',
            'db задач', 'db логинов', 'Логины']
headers1.each_with_index { |h, i| ws1.write(0, i, h, header_fmt) }

ws1.set_column(0, 0, 10)
ws1.set_column(1, 1, 40)
ws1.set_column(2, 2, 15)
ws1.set_column(3, 3, 15)
ws1.set_column(4, 4, 15)
ws1.set_column(5, 5, 12)
ws1.set_column(6, 6, 12)
ws1.set_column(7, 7, 15)
ws1.set_column(8, 8, 12)
ws1.set_column(9, 9, 12)
ws1.set_column(10, 10, 50)

row = 1
all_groups.each do |group|
  group_id = all_group_ids[group]
  logins_list = (sacct_logins_by_group[group] | db_logins_by_group[group]).to_a.sort.join(', ')

  quarters.each do |_, _, q_label|
    # Пропускаем кварталы, где нет данных
    has_sacct = sheet1_sacct[group][q_label].any?
    has_db = sheet1_db[group][q_label].any?
    next unless has_sacct || has_db

    # Строки по разделам
    all_partitions.each do |partition|
      sacct_vals = sheet1_sacct[group][q_label][partition]
      db_vals = sheet1_db[group][q_label][partition]

      next if sacct_vals[:node_hours] == 0 && sacct_vals[:job_count] == 0 &&
              db_vals[:node_hours] == 0 && db_vals[:job_count] == 0

      sacct_q_logins = sacct_logins_by_group_quarter[group][q_label].size
      db_q_logins = db_logins_by_group_quarter[group][q_label].size

      ws1.write(row, 0, group_id, integer_fmt)
      ws1.write(row, 1, group, cell_fmt)
      ws1.write(row, 2, q_label, cell_fmt)
      ws1.write(row, 3, partition, cell_fmt)
      ws1.write(row, 4, sacct_vals[:node_hours].round(2), number_fmt)
      ws1.write(row, 5, sacct_vals[:job_count], integer_fmt)
      ws1.write(row, 6, sacct_q_logins, integer_fmt)
      ws1.write(row, 7, db_vals[:node_hours].round(2), number_fmt)
      ws1.write(row, 8, db_vals[:job_count], integer_fmt)
      ws1.write(row, 9, db_q_logins, integer_fmt)
      ws1.write(row, 10, logins_list, cell_fmt)
      row += 1
    end

    # Итоговая строка по кварталу
    sacct_total_nh = all_partitions.sum { |p| sheet1_sacct[group][q_label][p][:node_hours] }
    sacct_total_jc = all_partitions.sum { |p| sheet1_sacct[group][q_label][p][:job_count] }
    db_total_nh = all_partitions.sum { |p| sheet1_db[group][q_label][p][:node_hours] }
    db_total_jc = all_partitions.sum { |p| sheet1_db[group][q_label][p][:job_count] }
    sacct_q_logins = sacct_logins_by_group_quarter[group][q_label].size
    db_q_logins = db_logins_by_group_quarter[group][q_label].size

    ws1.write(row, 0, group_id, total_fmt)
    ws1.write(row, 1, group, total_fmt)
    ws1.write(row, 2, q_label, total_fmt)
    ws1.write(row, 3, 'Итого', total_fmt)
    ws1.write(row, 4, sacct_total_nh.round(2), total_fmt)
    ws1.write(row, 5, sacct_total_jc, total_fmt)
    ws1.write(row, 6, sacct_q_logins, total_fmt)
    ws1.write(row, 7, db_total_nh.round(2), total_fmt)
    ws1.write(row, 8, db_total_jc, total_fmt)
    ws1.write(row, 9, db_q_logins, total_fmt)
    ws1.write(row, 10, logins_list, total_fmt)
    row += 1
  end

  # Итоговая строка за весь период
  sacct_all_nh = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet1_sacct[group][ql][p][:node_hours] } }
  sacct_all_jc = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet1_sacct[group][ql][p][:job_count] } }
  db_all_nh = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet1_db[group][ql][p][:node_hours] } }
  db_all_jc = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet1_db[group][ql][p][:job_count] } }
  sacct_total_logins = sacct_logins_by_group_total[group].size
  db_total_logins = db_logins_by_group_total[group].size

  ws1.write(row, 0, group_id, total_fmt)
  ws1.write(row, 1, group, total_fmt)
  ws1.write(row, 2, 'Всего', total_fmt)
  ws1.write(row, 3, '', total_fmt)
  ws1.write(row, 4, sacct_all_nh.round(2), total_fmt)
  ws1.write(row, 5, sacct_all_jc, total_fmt)
  ws1.write(row, 6, sacct_total_logins, total_fmt)
  ws1.write(row, 7, db_all_nh.round(2), total_fmt)
  ws1.write(row, 8, db_all_jc, total_fmt)
  ws1.write(row, 9, db_total_logins, total_fmt)
  ws1.write(row, 10, logins_list, total_fmt)
  row += 1
end

# ===== Лист 2: По логинам =====
ws2 = workbook.add_worksheet('По логинам')

headers2 = ['Логин', 'Квартал', 'Раздел', 'sacct узлочасы', 'sacct задач', 'db узлочасы', 'db задач']
headers2.each_with_index { |h, i| ws2.write(0, i, h, header_fmt) }

ws2.set_column(0, 0, 30)
ws2.set_column(1, 1, 15)
ws2.set_column(2, 2, 15)
ws2.set_column(3, 3, 15)
ws2.set_column(4, 4, 12)
ws2.set_column(5, 5, 15)
ws2.set_column(6, 6, 12)

row = 1
all_logins = (sheet2_sacct.keys + sheet2_db.keys).uniq.sort

all_logins.each do |login|
  quarters.each do |_, _, q_label|
    has_sacct = sheet2_sacct[login][q_label].any?
    has_db = sheet2_db[login][q_label].any?
    next unless has_sacct || has_db

    # Строки по разделам
    all_partitions.each do |partition|
      sacct_vals = sheet2_sacct[login][q_label][partition]
      db_vals = sheet2_db[login][q_label][partition]

      next if sacct_vals[:node_hours] == 0 && sacct_vals[:job_count] == 0 &&
              db_vals[:node_hours] == 0 && db_vals[:job_count] == 0

      ws2.write(row, 0, login, cell_fmt)
      ws2.write(row, 1, q_label, cell_fmt)
      ws2.write(row, 2, partition, cell_fmt)
      ws2.write(row, 3, sacct_vals[:node_hours].round(2), number_fmt)
      ws2.write(row, 4, sacct_vals[:job_count], integer_fmt)
      ws2.write(row, 5, db_vals[:node_hours].round(2), number_fmt)
      ws2.write(row, 6, db_vals[:job_count], integer_fmt)
      row += 1
    end

    # Итоговая строка по кварталу
    sacct_total_nh = all_partitions.sum { |p| sheet2_sacct[login][q_label][p][:node_hours] }
    sacct_total_jc = all_partitions.sum { |p| sheet2_sacct[login][q_label][p][:job_count] }
    db_total_nh = all_partitions.sum { |p| sheet2_db[login][q_label][p][:node_hours] }
    db_total_jc = all_partitions.sum { |p| sheet2_db[login][q_label][p][:job_count] }

    ws2.write(row, 0, login, total_fmt)
    ws2.write(row, 1, q_label, total_fmt)
    ws2.write(row, 2, 'Итого', total_fmt)
    ws2.write(row, 3, sacct_total_nh.round(2), total_fmt)
    ws2.write(row, 4, sacct_total_jc, total_fmt)
    ws2.write(row, 5, db_total_nh.round(2), total_fmt)
    ws2.write(row, 6, db_total_jc, total_fmt)
    row += 1
  end

  # Итоговая строка за весь период
  sacct_all_nh = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet2_sacct[login][ql][p][:node_hours] } }
  sacct_all_jc = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet2_sacct[login][ql][p][:job_count] } }
  db_all_nh = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet2_db[login][ql][p][:node_hours] } }
  db_all_jc = quarters.sum { |_, _, ql| all_partitions.sum { |p| sheet2_db[login][ql][p][:job_count] } }

  ws2.write(row, 0, login, total_fmt)
  ws2.write(row, 1, 'Всего', total_fmt)
  ws2.write(row, 2, '', total_fmt)
  ws2.write(row, 3, sacct_all_nh.round(2), total_fmt)
  ws2.write(row, 4, sacct_all_jc, total_fmt)
  ws2.write(row, 5, db_all_nh.round(2), total_fmt)
  ws2.write(row, 6, db_all_jc, total_fmt)
  row += 1
end

workbook.close
buffer.rewind

filename = "cluster_stats_#{cluster.name_ru.parameterize}_#{start_date}_#{end_date}_#{group_by}.xlsx"
File.write(filename, buffer.read)
puts "XLSX file saved: #{filename}"
