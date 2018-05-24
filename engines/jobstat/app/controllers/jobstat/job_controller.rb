require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper
    def show
      @job = Job.find(params["id"])
      @job_perf = @job.get_performance
      @ranking = @job.get_ranking
    end

    def post_info
      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)

      Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first_or_create
          .update({cluster: params["cluster"],
                   login: params["account"],
                   partition: params["partition"],
                   submit_time: Time.at(params["t_submit"]).utc.to_datetime,
                   start_time: Time.at(params["t_start"]).utc.to_datetime,
                   end_time: Time.at(params["t_end"]).utc.to_datetime,
                   timelimit: params["timelimit"],
                   command: params["command"],
                   state: params["state"],
                   num_cores: params["num_cores"],
                  })
    end

    def post_tags
      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)
      tags = params["tags"]
      job = Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      StringDatum.where(job_id: job.id).destroy_all

      tags.each do |name|
        StringDatum.where(job_id: job.id, name: "tag", value: name).first_or_create()
      end
    end

    def post_performance
      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)

      job = Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      FloatDatum.where(job_id: job.id).destroy_all

      FloatDatum.where(job_id: job.id, name: "cpu_user").first_or_create
          .update({value: params["avg"]["cpu_user"]})

      FloatDatum.where(job_id: job.id, name: "instructions").first_or_create
          .update({value: params["avg"]["fixed_counter1"]})

      FloatDatum.where(job_id: job.id, name: "gpu_load").first_or_create
          .update({value: params["avg"]["gpu_load"]})
      FloatDatum.where(job_id: job.id, name: "loadavg").first_or_create
          .update({value: params["avg"]["loadavg"]})

      if params["avg"].key?("ib_rcv_data")
        FloatDatum.where(job_id: job.id, name: "ib_rcv_data").first_or_create
            .update({value: params["avg"]["ib_rcv_data"]})
        FloatDatum.where(job_id: job.id, name: "ib_xmit_data").first_or_create
            .update({value: params["avg"]["ib_xmit_data"]})
      elsif params["avg"].key?("ib_rcv_data_mpi")
        FloatDatum.where(job_id: job.id, name: "ib_rcv_data").first_or_create
            .update({value: params["avg"]["ib_rcv_data_mpi"] + params["avg"]["ib_rcv_data_fs"]})
        FloatDatum.where(job_id: job.id, name: "ib_xmit_data").first_or_create
            .update({value: params["avg"]["ib_xmit_data_mpi"] + params["avg"]["ib_xmit_data_fs"]})
      end
    end
  end
end
