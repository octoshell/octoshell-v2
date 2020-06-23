#!/bin/bash
cd "$(dirname "$0")"

export HOST="http://localhost:5000"
export CLUSTER="lomonosov-2"
export ACC='admin_1'
export PART='compute'
export T=`date +%s`

LAST_ID=`psql -h localhost -U octo -t new_octoshell -c ' select max(drms_job_id) from jobstat_jobs;'`

JOB_ID=$((LAST_ID+1))

if [ "x$1" != x ]; then
  post_tags=0
else
  post_tags=1
fi

# echo "last id=$JOB_ID"
# exit 0

INFO='{
  "account": "'$ACC'",
  "command": "fake_command",
  "job_id": '"$JOB_ID"',
  "cluster": "'$CLUSTER'",
  "nodelist": "n48418", 
  "num_cores": 14,
  "num_nodes": 1,
  "partition": "'$PART'",
  "priority": 4294729060, 
  "state": "COMPLETED",
  "t_end": '"$((T - 100000 - $RANDOM))"',
  "t_start": '"$((T - 200000 - $RANDOM))"',
  "t_submit": '"$((T - 300000 - $RANDOM))"',
  "task_id": 0, 
  "timelimit": 259200, 
  "workdir": "fake_workdir"
}'

TAGS='{
  "job_id": '"$JOB_ID"',
  "cluster": "'$CLUSTER'",
  "tags": [
    "rule_normal_serial", 
    "rule_bad_locality", 
    "rule_not_effective", 
    "class_bad_locality", 
    "class_single", 
    "class_serial", 
    "class_less_suspicious", 
    "thr_low_l1_cache_miss", 
    "thr_low_mem_store", 
    "thr_low_mem_load", 
    "thr_low_ib_mpi", 
    "thr_low_gpu_load", 
    "thr_low_cpu_iowait", 
    "thr_low_cpu_nice", 
    "thr_low_cpu_system", 
    "thr_low_cpu_user", 
    "thr_low_loadavg", 
    "rule_mem_disbalance", 
    "rule_one_active_process", 
    "rule_wrong_partition_gpu", 
    "thr_low_l2_cache_miss"
  ], 
  "task_id": 0
}'

PERF='{
  "job_id": '"$JOB_ID"',
  "cluster": "'$CLUSTER'",

  "avg": {
   
    "cpu_iowait": 0.00252202132591562, 
    "cpu_nice": 0.0, 
    "cpu_system": 0.452331942512755, 
    "cpu_user": 3.34764487714418, 
    "fixed_counter1": 164619049.992754, 
    "fixed_counter2": 65706.6251253482, 
    "fixed_counter3": 98664632.1906222, 
    "gpu_load": 0.0, 
    "gpu_mem_load": 0.0, 
    "gpu_mem_usage": 0.0, 
    "ib_rcv_data_fs": 5640.88743625407, 
    "ib_rcv_data_mpi": 0.935808993973111, 
    "ib_rcv_pckts_fs": 120.896161335188, 
    "ib_rcv_pckts_mpi": 0.00571627260083449, 
    "ib_xmit_data_fs": 6627867.5321187, 
    "ib_xmit_data_mpi": 0.3350672229949, 
    "ib_xmit_pckts_fs": 121.013463143255, 
    "ib_xmit_pckts_mpi": 0.0011682892906815, 
    "ipc": 1.64777811846452, 
    "loadavg": 0.99086694483078, 
    "memory_free": 59182738.2905331, 
    "perf_counter1": 1054279.18002321, 
    "perf_counter2": 1079096.7151532, 
    "perf_counter3": 27417870.2084216, 
    "perf_counter4": 12044159.2276369
  }, 
  "max": {
    "cpu_idle": 100.0, 
    "cpu_iowait": 45.0, 
    "cpu_nice": 0.0, 
    "cpu_system": 24.0, 
    "cpu_user": 100.0, 
    "fixed_counter1": 6716118117.0, 
    "fixed_counter2": 13592296.0, 
    "fixed_counter3": 2264389423.63, 
    "gpu_load": 0.0, 
    "gpu_mem_load": 0.0, 
    "gpu_mem_usage": 0.0, 
    "ib_rcv_data_fs": 218274.93, 
    "ib_rcv_data_mpi": 1342.0, 
    "ib_rcv_pckts_fs": 5149.27, 
    "ib_rcv_pckts_mpi": 10.17, 
    "ib_xmit_data_fs": 224559432.0, 
    "ib_xmit_data_mpi": 326.4, 
    "ib_xmit_pckts_fs": 5151.47, 
    "ib_xmit_pckts_mpi": 1.13, 
    "ipc": 3.20930056165718, 
    "loadavg": 1.62, 
    "memory_free": 61121384.0, 
    "perf_counter1": 188266425.0, 
    "perf_counter2": 111703868.33, 
    "perf_counter3": 1676351094.33, 
    "perf_counter4": 535411580.0
  }, 
  "min": {
    "cpu_idle": 0.0, 
    "cpu_iowait": 0.0, 
    "cpu_nice": 0.0, 
    "cpu_system": 0.0, 
    "cpu_user": 0.0, 
    "fixed_counter1": 2233045.93, 
    "fixed_counter2": 0.0, 
    "fixed_counter3": 10103163.27, 
    "gpu_load": 0.0, 
    "gpu_mem_load": 0.0, 
    "gpu_mem_usage": 0.0, 
    "ib_rcv_data_fs": 545.07, 
    "ib_rcv_data_mpi": 0.0, 
    "ib_rcv_pckts_fs": 3.2, 
    "ib_rcv_pckts_mpi": 0.0, 
    "ib_xmit_data_fs": 460.4, 
    "ib_xmit_data_mpi": 0.0, 
    "ib_xmit_pckts_fs": 1.17, 
    "ib_xmit_pckts_mpi": 0.0, 
    "ipc": 0.145227933620309, 
    "loadavg": 0.0, 
    "memory_free": 56340236.0, 
    "perf_counter1": 60320.13, 
    "perf_counter2": 12989.17, 
    "perf_counter3": 561744.53, 
    "perf_counter4": 289109.93
  }
}'

MON_DATA='[
  {
    "avg": 3.13, 
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542015480
  }, 
  {
    "avg": 1.41,
    "avg_max": 45.4, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542023520
  }, 
  {
    "avg": 3.09,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542031560
  }, 
  {
    "avg": 3.23,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542039600
  }, 
  {
    "avg": 3.10,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542047640
  }, 
  {
    "avg": 3.36,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542055680
  }, 
  {
    "avg": 3.49,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542063720
  }, 
  {
    "avg": 3.49,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542071760
  }, 
  {
    "avg": 3.51,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542079800
  }, 
  {
    "avg": 3.45,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542087840
  }, 
  {
    "avg": 3.43,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542095880
  }, 
  {
    "avg": 3.57,
    "avg_max": 100.0, 
    "avg_min": 0.0, 
    "max": 100.0, 
    "min": 0.0, 
    "time": 1542103920
  }
]'


echo post info
curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/info" --data "$INFO"

if [ $post_tags = 1 ]; then
  echo post perf
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/performance" --data "$PERF" &

  echo post tags
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/tags" --data "$TAGS"

  echo post monitoring data
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=cpu_user" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=loadavg" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=gpu_load" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=ipc" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=ib_rcv_data_mpi" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=ib_xmit_data_mpi" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=ib_rcv_data_fs" --data "{\"data\": $MON_DATA}" &
  curl --request POST -H "Content-Type: application/json" "$HOST/jobstat/job/digest?cluster=$CLUSTER&job_id=$JOB_ID&name=ib_xmit_data_fs" --data "{\"data\": $MON_DATA}" &
fi

wait

echo ========================
echo $JOB_ID
echo ========================
