#!/usr/bin/env ruby
# find_idle_intervals.rb - Находит интервалы простоя в разделах Slurm
# с учётом перекрывающихся заданий и границ временного окна.

require 'time'

# ------------------------ Парсинг аргументов ------------------------
options = {
  start: '2025-01-01',
  end: '2026-01-01'

}

period_start = Time.parse(options[:start])
period_end   = Time.parse(options[:end])

if period_end <= period_start
  warn 'Ошибка: дата окончания должна быть позже даты начала.'
  exit 1
end

stdout = File.open('2025_jobs.txt')

# ------------------------ Парсинг и группировка ------------------------
# Храним интервалы для каждого раздела
jobs_by_part = Hash.new { |h, k| h[k] = [] }

stdout.each_line do |line|
  line.chomp!
  next if line.empty?

  part, start_str, end_str, _job_id, _state = line.split('|')
  part = part.split('_prio').first if part.include?('_prio')

  # part, start_str, end_str = line.split('|')
  next if part.nil? || part.empty?

  begin
    job_start = Time.parse(start_str)
    job_end   = Time.parse(end_str)

    # Обрезаем интервал до границ нашего периода
    eff_start = [job_start, period_start].max
    eff_end   = [job_end, period_end].min

    # Добавляем, только если есть пересечение (длительность > 0)
    jobs_by_part[part] << { start: eff_start, end: eff_end } if eff_start < eff_end
  rescue StandardError => e
    warn "Предупреждение: не удалось разобрать строку: #{line} (#{e.message})"
  end
end

# ------------------------ Объединение интервалов ------------------------
def merge_intervals(intervals)
  return [] if intervals.empty?

  sorted = intervals.sort_by { |i| i[:start] }
  merged = []
  sorted.each do |i|
    if merged.empty? || i[:start] > merged.last[:end]
      # нет пересечения/касания
      merged << i.dup
    else
      # пересекаются или касаются (если i[:start] <= merged.last[:end])
      merged.last[:end] = [merged.last[:end], i[:end]].max
    end
  end
  merged
end

# ------------------------ Поиск интервалов простоя ------------------------
def find_idle_intervals(merged_busy, period_start, period_end)
  idle = []
  # от начала периода до первой занятости
  if merged_busy.empty?
    idle << { start: period_start, end: period_end }
    return idle
  end

  # до первого
  idle << { start: period_start, end: merged_busy.first[:start] } if merged_busy.first[:start] > period_start

  # между занятыми
  merged_busy.each_cons(2) do |prev, nxt|
    idle << { start: prev[:end], end: nxt[:start] } if prev[:end] < nxt[:start]
  end

  # после последнего
  idle << { start: merged_busy.last[:end], end: period_end } if merged_busy.last[:end] < period_end

  idle
end

# ------------------------ Вывод результатов ------------------------
puts "\n" + '=' * 80
puts 'ИНТЕРВАЛЫ ПРОСТОЯ ПО РАЗДЕЛАМ'
puts "Период: #{options[:start]} — #{options[:end]}"
puts '=' * 80

total_period_seconds = period_end - period_start

if jobs_by_part.empty?
  puts "\nНет данных за указанный период."
  exit 0
end

jobs_by_part.each do |partition, intervals|
  # объединяем пересекающиеся интервалы занятости
  busy = merge_intervals(intervals)

  # находим простой
  idle_intervals = find_idle_intervals(busy, period_start, period_end)

  puts "\n📁 Раздел: #{partition}"
  puts '-' * 60

  if idle_intervals.empty?
    puts '  Нет простоев (раздел был занят всё время)'
  else
    # idle_intervals.each_with_index do |ii, idx|
    #   dur_sec = ii[:end] - ii[:start]
    #   dur_hours = dur_sec / 3600.0
    #   puts "  #{idx + 1}. #{ii[:start].strftime('%Y-%m-%d %H:%M:%S')} → " \
    #        "#{ii[:end].strftime('%Y-%m-%d %H:%M:%S')} " \
    #        "(#{'%.2f' % dur_hours} ч.)"
    # end

    # суммарный простой
    total_idle_sec = idle_intervals.sum { |ii| ii[:end] - ii[:start] }
    total_idle_hours = total_idle_sec / 3600.0
    percent_idle = (total_idle_sec / total_period_seconds * 100)

    puts "\n  📊 Всего простоев: #{'%.2f' % total_idle_hours} ч. (#{'%.1f' % percent_idle}% от периода)"

    CSV.open("results/#{partition}_#{'%.1f' % percent_idle}%_idle.csv", 'w') do |csv|
      csv << %w[Старт Конец Секунды Часы]
      idle_intervals.each do |i|
        dur_sec = i[:end] - i[:start]
        dur_hours = dur_sec / 3600.0
        csv << [i[:start], i[:end], dur_sec, '%.2f' % dur_hours]
      end
      # rows.each { |r| csv << r }
    end

  end
end
