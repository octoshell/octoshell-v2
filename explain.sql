
SELECT p.path,  COUNT(DISTINCT r.job_id),
DATE_FORMAT(FROM_UNIXTIME(MAX(r.start_time)), '%Y-%m-%d'), YEAR(FROM_UNIXTIME(r.start_time)) FROM (
SELECT 1 AS path
UNION All SELECT '/opt/BAK/'
UNION All SELECT '/opt/DOC/'
UNION All SELECT '/opt/Lost+Found.2/'
UNION All SELECT '/opt/Navisphere/'
) AS p
LEFT JOIN xalt_object AS o ON  o.object_path LIKE CONCAT(p.path, '%')
LEFT JOIN join_run_object AS j ON  o.obj_id = j.obj_id
LEFT JOIN  xalt_run AS r ON  r.run_id = j.run_id  AND r.job_id != 'unknown'
WHERE r.date >= '2023-01-01'
GROUP BY p.path, YEAR(FROM_UNIXTIME(r.start_time));
