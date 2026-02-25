#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'time'
require 'open3'
require 'csv'

# Класс для хранения информации о задаче
class SlurmTask
  attr_reader :partition, :submit, :exit

  # submit - время подачи (Time)
  # exit   - время выхода из очереди (Time) или nil, если задача ещё ожидает
  def initialize(partition, submit, exit_time)
    @partition = partition
    @submit    = submit
    @exit      = exit_time
  end

  # Проверяет, пересекает ли интервал задачи полуинтервал [day_start, day_end)
  def overlaps?(day_start, day_end)
    task_end = @exit || day_end
    task_end > day_start && @submit < day_end
  end

  # Возвращает [start, end] пересечения интервала задачи с днём
  def clip(day_start, day_end)
    task_end = @exit || day_end
    [@submit < day_start ? day_start : @submit,
     task_end > day_end ? day_end : task_end]
  end
end

# Парсит время из строки, возвращает Time или nil
def parse_time(str)
  return nil if str.nil? || str.empty? || str == 'Unknown'

  Time.parse(str)
rescue ArgumentError
  warn "Не удалось распарсить время: #{str}"
  nil
end

# Запрашивает все задачи через sacct за указанный интервал (по Start/End)
def fetch_all_tasks(start_time, end_time)
  # cmd = [
  #   'sacct',
  #   '-X', '-P',
  #   "--starttime=#{start_time}",
  #   "--endtime=#{end_time}",
  #   '--format=JobID,Partition,Submit,Start,End,State',
  #   '--noheader'
  # ]

  stdout = File.open('2025_jobs.txt')

  tasks = []
  stdout.each_line do |line|
    line.chomp!
    next if line.empty?

    fields = line.split('|')
    next if fields.size < 6

    _jobid, partition, submit_str, start_str, end_str, state = fields
    next if partition.nil? || partition.empty?

    submit = parse_time(submit_str)
    next if submit.nil?

    # Определяем время выхода из очереди
    exit_time = nil
    if start_str != 'Unknown'
      exit_time = parse_time(start_str)
    elsif end_str != 'Unknown'
      exit_time = parse_time(end_str)
    end
    # Если exit_time определён и он ≤ submit, игнорируем задачу (некорректные данные)
    next if exit_time && exit_time <= submit

    tasks << SlurmTask.new(partition, submit, exit_time)
  end

  tasks
end

# Вычисляет среднюю длину очереди для заданного набора задач и дня
def daily_average_queue_length(tasks, day_start, day_end)
  events = [] # [time, delta]

  tasks.each do |task|
    next unless task.overlaps?(day_start, day_end)

    start_in_day, end_in_day = task.clip(day_start, day_end)
    events << [start_in_day, +1]
    events << [end_in_day,   -1]
  end

  return 0.0 if events.empty?

  events.sort_by!(&:first)

  total = 0.0
  current_count = 0
  prev_time = nil

  events.each do |time, delta|
    if prev_time
      interval = time - prev_time
      total += interval * current_count if interval > 0
    end
    current_count += delta
    prev_time = time
  end

  total / (24 * 60 * 60) # среднее за день
end

# Основная программа
if ARGV.size < 2 || ARGV.size > 3
  puts "Использование: #{$PROGRAM_NAME} <start_date YYYY-MM-DD> <end_date YYYY-MM-DD> [buffer_days]"
  puts '  buffer_days - сколько дней расширить интервал запроса sacct (по умолчанию 7)'
  exit 1
end

begin
  start_date = Date.parse(ARGV[0])
  end_date   = Date.parse(ARGV[1])
rescue ArgumentError
  puts 'Ошибка: даты должны быть в формате YYYY-MM-DD'
  exit 1
end

if end_date < start_date
  puts 'Ошибка: конечная дата раньше начальной'
  exit 1
end

# Формируем временной интервал для sacct (по Start/End)
sacct_start = start_date.strftime('%Y-%m-%d')
sacct_end   = end_date.strftime('%Y-%m-%d')

puts "Запрашиваем задачи с #{sacct_start} по #{sacct_end} (по времени старта/завершения)..."
tasks = fetch_all_tasks(sacct_start, sacct_end)
puts "Получено задач: #{tasks.size}"

# Группируем задачи по разделам
tasks_by_partition = tasks.group_by(&:partition).sort.to_h
partitions = tasks_by_partition.keys.sort

if partitions.empty?
  puts 'Нет данных по разделам.'
  # Выводим только заголовок
  puts 'date'
  exit 0
end

# Создаём CSV
# csv = CSV.new($stdout, write_headers: true, headers: ['date'] + partitions)

CSV.open('jobs.csv', 'wb', write_headers: true, headers: ['date'] + partitions) do |csv|
  current_day = start_date
  while current_day < end_date
    day_start = Time.new(current_day.year, current_day.month, current_day.day, 0, 0, 0)
    day_end   = day_start + 24 * 60 * 60

    row = [current_day.to_s]
    puts row
    partitions.each do |part|
      avg = daily_average_queue_length(tasks_by_partition[part] || [], day_start, day_end)
      row << ('%.2f' % avg)
    end
    csv << row

    current_day += 1
  end
end
