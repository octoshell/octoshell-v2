# 46313
require 'csv'

year = 'YEAR(r.date)'
# paths = CSV.read('packets.csv').map(&:first)[1..4].map { |p| "('#{p}/')"}.join(",\n")

paths = CSV.read('packets.csv').map(&:first)[1..]

hardcoded =  "SELECT '#{paths[0]}/' AS path " +  paths[1..].map { |p| "UNION All SELECT '#{p}/'"}.join("\n")

sql = <<-SQL

SELECT p.path,  COUNT(o.object_path), MIN(o.object_path) FROM (
 #{hardcoded}
) AS p
LEFT JOIN xalt_object AS o ON  o.object_path LIKE CONCAT(p.path, '%')
GROUP BY p.path
SQL

File.write('xalt_objects.sql', sql)
