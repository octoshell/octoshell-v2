module Jobstat
  class ApiController < ActionController::Base
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
                   nodelist: params["nodelist"],
                   command: params["command"],
                   state: params["state"],
                   num_cores: params["num_cores"],
                   num_nodes: params["num_nodes"],
                  })
    end

    CHECKER_PREFIX = '[                checker                ]'

    def add_notice(job, user)
      Core::Notice.where(sourceable: user, linkable: job, category: 1).destroy_all
      note=Core::Notice.create(
        sourceable: user,
        message: "bad job - #{view_context.link_to job.drms_job_id, jobstat.job_path(job)}",
        linkable: job,
        category: 1)
      note.save!
      logger.info "#{CHECKER_PREFIX}: new notice for #{job.drms_job_id}"
    end

    def remove_notice(job, user)
      Core::Notice.where(sourceable: user, linkable: job, category: 1).destroy_all
      logger.info CHECKER_PREFIX + ": removed notice for #{job.drms_job_id}"
    end

    def group_match(job, user)
      job.get_rules(user).each { |r|
        return true if r.group == 'disaster'
      }
      return false
    end

    def time_match(job)
      return job.end_time > Time.new && job.state != 'COMPLETED'
    end

    def check_job(job)
      logger.info CHECKER_PREFIX + ": checking job #{job.id}: state = #{job.state}, end_time = #{job.end_time}"

      user = Core::Member.where(login: job.login).take.user

      if group_match(job, user) && time_match(job)
        add_notice(job, user)
      else
        remove_notice(job, user)
      end
    end

    def post_tags
      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)
      tags = params["tags"]
      job = Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      StringDatum.where(job_id: job.id).destroy_all

      return if tags.nil?
      tags.each do |name|
        StringDatum.where(job_id: job.id, name: "tag", value: name).first_or_create()
      end

      check_job(job)
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

      FloatDatum.where(job_id: job.id, name: "ipc").first_or_create
          .update({value: params["avg"]["ipc"]})

      FloatDatum.where(job_id: job.id, name: "ib_rcv_data_fs").first_or_create
          .update({value: params["avg"]["ib_rcv_data_fs"]})
      FloatDatum.where(job_id: job.id, name: "ib_xmit_data_fs").first_or_create
          .update({value: params["avg"]["ib_xmit_data_fs"]})

      FloatDatum.where(job_id: job.id, name: "ib_rcv_data_mpi").first_or_create
          .update({value: params["avg"]["ib_rcv_data_mpi"]})
      FloatDatum.where(job_id: job.id, name: "ib_xmit_data_mpi").first_or_create
          .update({value: params["avg"]["ib_xmit_data_mpi"]})
    end
    
    def post_digest
      return unless params.key?("data")
      return if params["data"].nil?

      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)

      job = Job.where(drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      DigestFloatDatum.where(job_id: job.id, name: params["name"]).destroy_all

      params["data"].each do |entry|
	      DigestFloatDatum.where(job_id: job.id, name: params["name"], time: Time.at(entry["time"]).utc.to_datetime).first_or_create
          .update({value: entry["avg"]})
      end
    end

    #before_filter :parse_request, :authenticate_from_token!, only: [:push]

    protected

    def authenticate_from_token!
      if !@json['api_token']
        render nothing: true, status: :forbidden
      end
      @json.delete['api_token']
    end

    def parse_request
      @json = JSON.parse(request.body.read)
    end
  end
end
