module Jobstat
  class ApiController < ActionController::Base
    include AbnormalJobChecker

    before_action :parse_request
    http_basic_authenticate_with name: Rails.application.secrets.jobstat[:user],
                                 password: Rails.application.secrets.jobstat[:password]
    def post_info
      Job.update_job(@json).notify_when_finished
    end

    def fetch_job_or_404(params)
      cluster = params['cluster']
      drms_job_id = params['job_id']
      drms_task_id = params.fetch('task_id', 0)

      job = Job.where(cluster: cluster, drms_job_id: drms_job_id,
                      drms_task_id: drms_task_id).first

      if job.nil?
        logger.error "ERROR(jobstat): Basic job info not found: #{cluster} #{drms_job_id}"
        head 404
      end

      return job
    end

    def post_tags
      job = fetch_job_or_404(@json)
      return if job.nil?

      tags = @json['tags']
      StringDatum.where(job_id: job.id, name: 'tag').destroy_all

      return if tags.nil?

      rules = []
      tags.each do |name|
        StringDatum.where(job_id: job.id, name: 'tag', value: name).first_or_create()

        rules << name if name.start_with?("rule_")
      end

      JobNotificationEvent.create_from_job(job, rules)

      check_job(job)

      head 200
    end

    def post_detailed
      job = fetch_job_or_404(@json)
      return if job.nil?

      origin_cluster = @json['origin']['cluster']
      origin_drms_job_id = @json['origin']['job_id']
      origin_drms_task_id = @json['origin'].fetch('task_id', 0)

      origin_job = Job.where(cluster: origin_cluster, drms_job_id: origin_drms_job_id, drms_task_id: origin_drms_task_id).first()

      origin_job.initiatees << job
      job.initiator = origin_job

      StringDatum.where(job_id: job.id, name: 'extra_data').first_or_create.update({value: @json['extra_data'].to_json})

      dt_name = 'detailed_types'

      StringDatum.where(job_id: job.id, name: dt_name).destroy_all
      detailed_types = @json[dt_name]
      detailed_types and detailed_types.each do |name|
          StringDatum.where(job_id: job.id, name: dt_name, value: name).first_or_create()
      end

      StringDatum.where(job_id: job.id, name: 'detailed').destroy_all
      tags = @json['tags']
      tags and tags.each do |name|
          StringDatum.where(job_id: job.id, name: 'detailed', value: name).first_or_create()
      end

      check_job(job)
      head 200
    end

    def post_performance
      job = fetch_job_or_404(@json)
      return if job.nil?

      FloatDatum.where(job_id: job.id).destroy_all

      FloatDatum.where(job_id: job.id, name: 'cpu_user').first_or_create
          .update({value: @json['avg']['cpu_user']})

      FloatDatum.where(job_id: job.id, name: 'instructions').first_or_create
          .update({value: @json['avg']['fixed_counter1']})

      FloatDatum.where(job_id: job.id, name: 'gpu_load').first_or_create
          .update({value: @json['avg']['gpu_load']})
      FloatDatum.where(job_id: job.id, name: 'loadavg').first_or_create
          .update({value: @json['avg']['loadavg']})

      FloatDatum.where(job_id: job.id, name: 'ipc').first_or_create
          .update({value: @json['avg']['ipc']})

      FloatDatum.where(job_id: job.id, name: 'ib_rcv_data_fs').first_or_create
          .update({value: @json['avg']['ib_rcv_data_fs']})
      FloatDatum.where(job_id: job.id, name: 'ib_xmit_data_fs').first_or_create
          .update({value: @json['avg']['ib_xmit_data_fs']})

      FloatDatum.where(job_id: job.id, name: 'ib_rcv_data_mpi').first_or_create
          .update({value: @json['avg']['ib_rcv_data_mpi']})
      FloatDatum.where(job_id: job.id, name: 'ib_xmit_data_mpi').first_or_create
          .update({value: @json['avg']['ib_xmit_data_mpi']})

      head 200
    end

    def post_digest
      return unless params.key?('data')
      return if params['data'].nil?

      job = fetch_job_or_404(params)
      return if job.nil?

      DigestFloatDatum.where(job_id: job.id, name: params['name']).destroy_all

      params['data'].each do |entry|
      DigestFloatDatum.where(job_id: job.id, name: params['name'], time: Time.at(entry['time']).utc.to_datetime).first_or_create
          .update({value: entry['avg']})
      end

      head 200
    end

    def check_exist
      job = fetch_job_or_404(params)
      return if job.nil?

      head 200
    end

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
