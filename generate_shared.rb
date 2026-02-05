# 46313
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
LEFT JOIN xalt_object AS o ON  o.object_path LIKE CONCAT(p.path, '%')
LEFT JOIN join_run_object AS j ON  o.obj_id = j.obj_id AND j.run_id >= #{min_run_id}
LEFT JOIN  xalt_run AS r ON  r.run_id = j.run_id  AND r.job_id != 'unknown'
GROUP BY p.path, #{year};
SQL

File.write('runs_by_path.sql', sql)
