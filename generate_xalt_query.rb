# 42629
require 'csv'

year = 'YEAR(r.date)'
min_run_id = 14149541
# paths = CSV.read('packets.csv').map(&:first)[1..4].map { |p| "('#{p}/')"}.join(",\n")

paths = CSV.read('packets.csv').map(&:first)[1..]

hardcoded =  "SELECT '#{paths[0]}/' AS path " +  paths[1..].map { |p| "UNION All SELECT '#{p}/'"}.join("\n")

sql = <<-SQL

SELECT p.path,  COUNT(DISTINCT r.job_id), MAX(r.date), #{year} FROM (
 #{hardcoded}
) AS p
LEFT JOIN  xalt_run AS r ON  r.exec_path LIKE CONCAT(p.path, '%')  AND
  r.job_id != 'unknown' AND r.run_id >= #{min_run_id}
GROUP BY p.path, #{year};
SQL

File.write('runs_by_path.sql', sql)
