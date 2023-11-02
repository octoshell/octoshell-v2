# == Schema Information
#
# Table name: jobstat_jobs
#
#  id           :integer          not null, primary key
#  cluster      :string(32)       not null
#  command      :string(1024)
#  end_time     :datetime
#  login        :string(32)
#  nodelist     :text
#  num_cores    :bigint(8)
#  num_nodes    :bigint(8)
#  partition    :string(32)
#  start_time   :datetime
#  state        :string(32)
#  submit_time  :datetime
#  timelimit    :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  drms_job_id  :bigint(8)        not null
#  drms_task_id :bigint(8)
#
# Indexes
#
#  index_jobstat_jobs_on_end_time     (end_time)
#  index_jobstat_jobs_on_login        (login)
#  index_jobstat_jobs_on_partition    (partition)
#  index_jobstat_jobs_on_start_time   (start_time)
#  index_jobstat_jobs_on_state        (state)
#  index_jobstat_jobs_on_submit_time  (submit_time)
#  uniq_jobs                          (cluster,drms_job_id,drms_task_id) UNIQUE
#

require 'yaml/store'
# require "uri"
# require "net/http"
# require "net/https"

module Jobstat
  class Job < ApplicationRecord
    include JobHelper
    has_many :initiatees, class_name: "Job", foreign_key: "initiator_id"
    belongs_to :initiator, class_name: "Job"

    belongs_to :member, class_name: "Core::Member", primary_key: :login
    NOTIFY_FINAL_STATES = %w[COMPLETED CANCELLED FAILED
                             NODE_FAIL TIMEOUT unknown].freeze
    NOTIFY_PREVIOUS_STATES = (%w[CONFIGURING RESIZING RUNNING] + [nil]).freeze

    def notify_when_finished
      return unless state_previously_changed? &&
                    NOTIFY_PREVIOUS_STATES.include?(state_previous_change[0]) &&
                    NOTIFY_FINAL_STATES.include?(state_previous_change[1])

      Jobstat::Worker.perform_async(id)

    end

    def get_duration_hours
      (end_time - start_time) / 3600
    end

    def get_cpuh
      get_duration_hours * num_cores
    end

    def get_performance
      all_data = FloatDatum.where(job_id: id)

      data = {
        cpu_user: nil,
        instructions: nil,
        gpu_load: nil,
        loadavg: nil,
        ipc: nil,
        ib_rcv_data_fs: nil,
        ib_xmit_data_fs: nil,
        ib_rcv_data_mpi: nil,
        ib_xmit_data_mpi: nil,
      }

      all_data.each{|d| data[d.name.to_sym]=d.value}

      # cpu_user = FloatDatum.where(job_id: id, name: "cpu_user").take
      # instructions = FloatDatum.where(job_id: id, name: "instructions").take
      # gpu_load = FloatDatum.where(job_id: id, name: "gpu_load").take
      # loadavg = FloatDatum.where(job_id: id, name: "loadavg").take
      # ipc = FloatDatum.where(job_id: id, name: "ipc").take
      # ib_rcv_data_fs = FloatDatum.where(job_id: id, name: "ib_rcv_data_fs").take
      # ib_xmit_data_fs = FloatDatum.where(job_id: id, name: "ib_xmit_data_fs").take
      # ib_rcv_data_mpi = FloatDatum.where(job_id: id, name: "ib_rcv_data_mpi").take
      # ib_xmit_data_mpi = FloatDatum.where(job_id: id, name: "ib_xmit_data_mpi").take

      # data = {
      #   cpu_user: if !cpu_user.nil? then cpu_user.value else nil end,
      #   instructions: if !instructions.nil? then instructions.value else nil end,
      #   gpu_load: if !gpu_load.nil? then gpu_load.value else nil end,
      #   loadavg: if !loadavg.nil? then loadavg.value else nil end,
      #   ipc: if !ipc.nil? then ipc.value else nil end,
      #   ib_rcv_data_fs: if !ib_rcv_data_fs.nil? then ib_rcv_data_fs.value else nil end,
      #   ib_xmit_data_fs: if !ib_xmit_data_fs.nil? then ib_xmit_data_fs.value else nil end,
      #   ib_rcv_data_mpi: if !ib_rcv_data_mpi.nil? then ib_rcv_data_mpi.value else nil end,
      #   ib_xmit_data_mpi: if !ib_xmit_data_mpi.nil? then ib_xmit_data_mpi.value else nil end,
      # }

      data[:ib_rcv_data_fs] /= 1024 * 1024 unless data[:ib_rcv_data_fs].nil?
      data[:ib_xmit_data_fs] /= 1024 * 1024 unless data[:ib_xmit_data_fs].nil?
      data[:ib_rcv_data_mpi] /= 1024 * 1024 unless data[:ib_rcv_data_mpi].nil?
      data[:ib_xmit_data_mpi] /= 1024 * 1024 unless data[:ib_xmit_data_mpi].nil?

      return data
    end

    def get_ranking
      performance = get_performance

      low_str = 'low'
      average_str = 'average'
      high_str = 'high'

      {
        cpu_user: get_one_rank(performance[:cpu_user], low_str, 20, average_str, 80, high_str),
        instructions: get_one_rank(performance[:instructions], low_str, 100000000, average_str, 400000000, high_str),
        gpu_load: get_one_rank(performance[:gpu_load], low_str, 20, average_str, 80, high_str),
        loadavg: (cluster=='lomonosov-1' ?
          get_one_rank(performance[:loadavg], low_str, 2, average_str, 7, high_str, 15, low_str) :
          get_one_rank(performance[:loadavg], low_str, 2, average_str, 7, high_str, 29, low_str)),
        ipc: get_one_rank(performance[:ipc], low_str, 0.5, average_str, 1.0, high_str),
        ib_xmit_data_fs: get_one_rank(performance[:ib_xmit_data_fs], low_str, 10, average_str, 100, high_str),
        ib_rcv_data_fs: get_one_rank(performance[:ib_rcv_data_fs], low_str, 10, average_str, 100, high_str),
        ib_xmit_data_mpi: get_one_rank(performance[:ib_xmit_data_mpi], low_str, 10, average_str, 100, high_str),
        ib_rcv_data_mpi: get_one_rank(performance[:ib_rcv_data_mpi], low_str, 10, average_str, 100, high_str),
      }
    end

    def slice(dict, vals)
      result = []
      vals.each do |val|
        begin
          result.push(dict.fetch(val))
        rescue KeyError
        end
      end
      result
    end

    def priority_filtration(entries)
      result = []

      max_priority = {}

      entries.each do |condition|
        current_priority = max_priority.fetch(condition['group'], 0)

        if condition['priority'] > current_priority
          max_priority[condition['group']] = condition['priority']
        end
      end

      entries.each do |condition|
        if condition['priority'] >= max_priority[condition['group']]
          result.push(condition)
        end
      end

      result
    end

    def get_not_public_by_type(types)
      result = []

      types.each do |section_name|
        (Job.rules[section_name] || {}).each do |condition, fields|
          if fields['public'] == 0
            result << condition
          end
        end
      end
      result
    end

# primary
    def get_primary_types
      ['classes', 'thresholds', 'rules']
    end

    def get_primary_names
      names = StringDatum.where(job_id: id, name: "tag").pluck(:value)
      names - get_not_public_by_type(get_primary_types)
    end

    def get_thresholds
      slice(Job.rules['thresholds'], get_primary_names)
    end

    def get_classes
      priority_filtration(slice(Job.rules['classes'], get_primary_names))
    end

    def get_rules user
      filters = Job::get_filters(user)
      if filters.length > 0
        filters = filters[-1]["filters"] || []
      end

      names = get_primary_names - filters # remove rules wich are filtered out

      result = priority_filtration(slice(Job.rules['rules'], names)) # sort by groups priority
      result.each do |type|
        type["modules"] = type["module_recommendation"].split(",").map {|x| Job.rules['detailed_analysis_types'][x]||{} }.reject{|x| x.empty?}
      end
      result
    end

# detailed

    def get_detailed_types
      types = []

      Job.rules['detailed_analysis_types'].each do |name, _|
        types << name
      end

      types
    end

    def get_extra_data
      extra_data = StringDatum.where(job_id: id, name: "extra_data").first
      if extra_data
        return JSON.parse(extra_data.value)
      else
        return {}
      end
    end

    def get_detailed_names
      names = StringDatum.where(job_id: id, name: "detailed").pluck(:value)
      names - get_not_public_by_type(get_detailed_types)
    end

    def get_detailed
      result = {}

      get_detailed_types.each do |type|
        (Job.rules['detailed'][type]||{}).each do |k,sub_type|
          sub_type['type'] = type
        end
        result = result.merge(Job.rules['detailed'][type] || {})
      end
      result = slice(result, get_detailed_names)
      result.each do |type|
        type["modules"] = type["module_recommendation"].split(",").map {|x| Job.rules['detailed_analysis_types'][x]||{} }.reject{|x| x.empty?}
      end
      result
    end

    def get_detailed_by_type(type)
      slice(Job.rules[type], get_detailed_names)
    end

    # def get_cached data

    #   Rails.cache.fetch(data) do
    #     result=yield
    #     cache_db.transaction do
    #       if result
    #         cache_db[data]=result
    #       else
    #         result=cache_db[data]
    #       end
    #     end
    #     result
    #   end
    # end

    # def cache_db

    #   # FIXME! change path...
    #   @@cache_db_singleton ||= YAML::Store.new "engines/jobstat/cache.yaml"
    # end

    def get_user login
      member=Core::Member.all.where(login: login).last
      if member
        member.user
      else
        nil
      end
    end

    def self.get_filters(user)
      # return []
      # user=get_user login
      # user_id=nil
      # if user
      #   user_id=user.id
      # else
      #   #!!!!!! DEBUG ONLY! return nil
      #   user_id=4
      # end
      user_id=user.id

      data=get_data("jobstat:filters:#{user_id}",
        URI("#{Rails.application.config.octo_feedback_host}/api/filters?user=#{user_id}"))
      # logger.info "get_filters: data=#{data.inspect}"
      data || []
    end

    def self.get_feedback_job user_id, joblist=[]

      jobs=joblist.kind_of?(Array) ? joblist.join(',') : joblist

      get_data("jobstat:feedback_job:#{user_id}:#{jobs}",
        URI("#{Rails.application.config.octo_feedback_host}/api/feedback-job?user=#{user_id}&cluster=lomonosov-2&job_id=#{jobs}")
        )
    end

    def self.post_data(uri,data)
      begin
        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https',
          :verify_mode => OpenSSL::SSL::VERIFY_NONE,
          :read_timeout => 5,
          :opent_imeout => 5,
          :ssl_timeout => 5,
          ) do |http|
          request = Net::HTTP::Post.new uri.request_uri
          #request.basic_auth 'username', 'password'
          logger.info "post_data posting to #{uri.inspect} body=#{data.inspect}"
          request.set_form_data data

          response = http.request request
          logger.info "post_data: #{response.code}/#{response.body}"
          response
        end
      rescue => e #Net::ReadTimeout, Net::OpenTimeout
        logger.info "post_data: error #{e.message}; #{e.backtrace.join("\n")}"
        nil
      end
    end

    # FIXME! make this more customizable, not hardcoded!
    def get_command
      array = command.split
      if /\/ompi$/.match(array[0]) ||
         /\/impi$/.match(array[0]) ||
         /\/run$/.match(array[0])
      then
        array.shift
      end
      if /([^\/]+)$/.match array[0]
        $1
      else
        array[0]
      end
    end

    def self.agree_flags
      {
        0 => 'far fa-thumbs-up agreed-flag',
        1 => 'far fa-thumbs-down agreed-flag',
        99 => 'far fa-clock agreed-flag',
      }
    end

    def self.rules force_reload=false
      if @rules.nil? || force_reload
        @rules={}
        begin
          File.open("engines/jobstat/config/conditions.json", "r") { |file|
            @rules=JSON.load(file)
          }
        rescue
        end
      end
      @rules
    end

    private

    def self.get_data(id,uri)
      CacheData.get(id) do
        begin
          Net::HTTP.start(uri.host, uri.port,
            :use_ssl => uri.scheme == 'https',
            :verify_mode => OpenSSL::SSL::VERIFY_NONE,
            :read_timeout => 5,
            :opent_imeout => 5,
            :ssl_timeout => 5,
            ) do |http|
            request = Net::HTTP::Get.new uri.request_uri
            #request.basic_auth 'username', 'password'

            response = http.request request
            if Net::HTTPSuccess === response
              if response.body.length==0
                logger.info "get_data #{uri}: Empty response..."
                nil
              else
                json=JSON.load(response.body)
                #json['filters'].split ','
                logger.info "get_data #{uri} for #{id}: #{json}"
                json
              end
            else
              logger.info "get_data #{uri}: Bad response, code=#{response.code}, body=#{response.body}"
              nil
            end
          end
        rescue => e #Net::ReadTimeout, Net::OpenTimeout
          logger.info "get_data #{uri}: error #{e.message}; #{e.backtrace.join("\n")}"
          nil
        end
      end
    end
  end
end
