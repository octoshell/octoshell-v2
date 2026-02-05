

SELECT  o.object_path,  COUNT(DISTINCT r.job_id), MAX(r.date)  from xalt_run  r
JOIN join_run_object as j on j.run_id = r.run_id
JOIN xalt_object AS o on  o.obj_id = j.obj_id  WHERE r.job_id != 'unknown' AND
o.object_path LIKE '/opt%'
GROUP BY o.object_path;
