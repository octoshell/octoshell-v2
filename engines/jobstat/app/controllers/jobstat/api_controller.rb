module Jobstat
  class ApiController < ActionController::Base
    before_action :parse_request
    #before_action :parse_request, :authenticate_from_token!, only: [:push]

    def post_info
      cluster = @json["cluster"]
      drms_job_id = @json["job_id"]
      drms_task_id = @json.fetch("task_id", 0)

      Job.where(cluster: @json["cluster"], drms_job_id: drms_job_id, drms_task_id: drms_task_id).first_or_create
          .update({login: @json["account"],
                   partition: @json["partition"],
                   submit_time: Time.at(@json["t_submit"]).utc.to_datetime,
                   start_time: Time.at(@json["t_start"]).utc.to_datetime,
                   end_time: Time.at(@json["t_end"]).utc.to_datetime,
                   timelimit: @json["timelimit"],
                   nodelist: @json["nodelist"],
                   command: @json["command"],
                   state: @json["state"],
                   num_cores: @json["num_cores"],
                   num_nodes: @json["num_nodes"],
                  })
    end

    CHECKER_PREFIX = '[                checker                ]'

    def add_notice(job, user)
      Core::Notice.where(sourceable: user, linkable: job, category: 1).destroy_all
      note=Core::Notice.create(
        sourceable: user,
        message: view_context.link_to(job.drms_job_id, jobstat.job_path(job)),
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
        return true if r['group'] == 'disaster'
      }
      return false
    end

    def time_match(job)
      return job.end_time > Time.new && job.state != 'COMPLETED'
    end

    def check_job(job)
      logger.info CHECKER_PREFIX + ": checking job #{job.id}: state = #{job.state}, end_time = #{job.end_time}"
      logger.info "EVERYTHING ABOUT JOB: #{job.inspect}"
      user = Core::Member.where(login: job.login).take.user

      if group_match(job, user) && time_match(job)
        add_notice(job, user)
      else
        remove_notice(job, user)
      end
    end

    def post_tags
      cluster = @json["cluster"]
      drms_job_id = @json["job_id"]
      drms_task_id = @json.fetch("task_id", 0)

      tags = @json["tags"]
      job = Job.where(cluster: cluster, drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      StringDatum.where(job_id: job.id, name: "tag").destroy_all

      return if tags.nil?
      tags.each do |name|
        StringDatum.where(job_id: job.id, name: "tag", value: name).first_or_create()
      end

      check_job(job)
    end

    def post_detailed
      cluster = @json["cluster"]
      drms_job_id = @json["job_id"]
      drms_task_id = @json.fetch("task_id", 0)

      origin_cluster = @json["origin"]["cluster"]
      origin_drms_job_id = @json["origin"]["job_id"]
      origin_drms_task_id = @json["origin"].fetch("task_id", 0)

      tags = @json["tags"]

      job = Job.where(cluster: cluster, drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()
      origin_job = Job.where(cluster: origin_cluster, drms_job_id: origin_drms_job_id, drms_task_id: origin_drms_task_id).first()

      origin_job.initiatees << job
      job.initiator = origin_job

      StringDatum.where(job_id: job.id, name: "extra_data").first_or_create.update({value: @json["extra_data"].to_json})

      StringDatum.where(job_id: job.id, name: "detailed").destroy_all

      tags and tags.each do |name|
          StringDatum.where(job_id: job.id, name: "detailed", value: name).first_or_create()
      end

      check_job(job)
    end

    def post_performance
      cluster = @json["cluster"]
      drms_job_id = @json["job_id"]
      drms_task_id = @json.fetch("task_id", 0)

      job = Job.where(cluster: cluster, drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      FloatDatum.where(job_id: job.id).destroy_all

      FloatDatum.where(job_id: job.id, name: "cpu_user").first_or_create
          .update({value: @json["avg"]["cpu_user"]})

      FloatDatum.where(job_id: job.id, name: "instructions").first_or_create
          .update({value: @json["avg"]["fixed_counter1"]})

      FloatDatum.where(job_id: job.id, name: "gpu_load").first_or_create
          .update({value: @json["avg"]["gpu_load"]})
      FloatDatum.where(job_id: job.id, name: "loadavg").first_or_create
          .update({value: @json["avg"]["loadavg"]})

      FloatDatum.where(job_id: job.id, name: "ipc").first_or_create
          .update({value: @json["avg"]["ipc"]})

      FloatDatum.where(job_id: job.id, name: "ib_rcv_data_fs").first_or_create
          .update({value: @json["avg"]["ib_rcv_data_fs"]})
      FloatDatum.where(job_id: job.id, name: "ib_xmit_data_fs").first_or_create
          .update({value: @json["avg"]["ib_xmit_data_fs"]})

      FloatDatum.where(job_id: job.id, name: "ib_rcv_data_mpi").first_or_create
          .update({value: @json["avg"]["ib_rcv_data_mpi"]})
      FloatDatum.where(job_id: job.id, name: "ib_xmit_data_mpi").first_or_create
          .update({value: @json["avg"]["ib_xmit_data_mpi"]})
    end
    
    def post_digest
      return unless params.key?("data")
      return if params["data"].nil?

      cluster = params["cluster"]
      drms_job_id = params["job_id"]
      drms_task_id = params.fetch("task_id", 0)

      job = Job.where(cluster: cluster, drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      DigestFloatDatum.where(job_id: job.id, name: params["name"]).destroy_all

      params["data"].each do |entry|
	      DigestFloatDatum.where(job_id: job.id, name: params["name"], time: Time.at(entry["time"]).utc.to_datetime).first_or_create
          .update({value: entry["avg"]})
      end
    end

    def check_exist
      cluster = @json["cluster"]
      drms_job_id = Integer(@json["job_id"])
      drms_task_id = Integer(@json.fetch("task_id", 0))

      @job = Job.where(cluster: cluster, drms_job_id: drms_job_id, drms_task_id: drms_task_id).first()

      render :status => 404 unless @job
    end

    before_action :parse_request

    protected

    def authenticate_from_token!
      if !@json['api_token']
        render nothing: true, status: :forbidden
      end
      @json.delete['api_token']
    end

    def parse_request
      begin
        @json = JSON.parse(request.body.read)
      rescue
        @json = {}
      end
    end
  end
end
