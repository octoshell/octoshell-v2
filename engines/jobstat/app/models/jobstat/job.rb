# == Schema Information
#
# Table name: jobstat_jobs
#
#  id           :integer          not null, primary key
#  cluster      :string(32)
#  drms_job_id  :integer
#  drms_task_id :integer
#  login        :string(32)
#  partition    :string(32)
#  submit_time  :datetime
#  start_time   :datetime
#  end_time     :datetime
#  timelimit    :integer
#  command      :string(1024)
#  state        :string(32)
#  num_cores    :integer
#  num_nodes    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  nodelist     :text
#

require 'yaml/store'
# require "uri"
# require "net/http"
# require "net/https"

module Jobstat
  class Job < ActiveRecord::Base
    include JobHelper

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


    def get_tags
      tags=StringDatum.where(job_id: id, name: "tag").pluck(:value)
    end

    def get_ranking
      performance = get_performance
      
      {
        cpu_user: get_one_rank(performance[:cpu_user], 'low', 20, 'average', 80, 'good'),
        # get_cpu_user_ranking(performance[:cpu_user]),
        instructions: get_one_rank(performance[:instructions], 'low', 100000000, 'average', 400000000, 'good'),
        # get_instructions_ranking(performance[:instructions]),
        gpu_load: get_one_rank(performance[:gpu_load], 'low', 20, 'average', 80, 'good'),
        # get_gpu_load_ranking(performance[:gpu_load]),
        loadavg: (cluster=='lomonosov-1' ?
          get_one_rank(performance[:loadavg], 'low', 2, 'average', 7, 'good', 15, 'low') :
          get_one_rank(performance[:loadavg], 'low', 2, 'average', 7, 'good', 29, 'low')),
        # get_loadavg_ranking(performance[:loadavg], cluster),
        ipc: get_one_rank(performance[:ipc], 'low', 0.5, 'average', 1.0, 'good'),
        # get_ipc_ranking(performance[:ipc]),
        ib_xmit_data_fs: get_one_rank(performance[:ib_xmit_data_fs], 'low', 10, 'average', 100, 'good'),
        # get_ib_xmit_data_fs_ranking(performance[:ib_xmit_data_fs]),
        ib_rcv_data_fs: get_one_rank(performance[:ib_rcv_data_fs], 'low', 10, 'average', 100, 'good'),
        # get_ib_rcv_data_fs_ranking(performance[:ib_rcv_data_fs]),
        ib_xmit_data_mpi: get_one_rank(performance[:ib_xmit_data_mpi], 'low', 10, 'average', 100, 'good'),
        #get_ib_xmit_data_mpi_ranking(performance[:ib_xmit_data_mpi]),
        ib_rcv_data_mpi: get_one_rank(performance[:ib_rcv_data_mpi], 'low', 10, 'average', 100, 'good'),
        # get_ib_rcv_data_mpi_ranking(performance[:ib_rcv_data_mpi]),
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
        current_priority = max_priority.fetch(condition.group, 0)

        if condition.priority > current_priority
          max_priority[condition.group] = condition.priority
        end
      end

      entries.each do |condition|
        if condition.priority >= max_priority[condition.group]
          result.push(condition)
        end
      end

      result
    end

    def get_thresholds
      slice(Conditions.instance.thresholds, get_tags)
    end

    def get_classes
      priority_filtration(slice(Conditions.instance.classes, get_tags))
    end

    def get_rules user
      filters=Job::get_filters(user)|| []
      tags=get_tags
      tags=tags - filters
      priority_filtration(slice(Conditions.instance.rules, tags))
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

    def self.get_filters user

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
        URI("http://graphit.parallel.ru:8123/api/filters?user=#{user_id}"))
      #logger.info "get_filters: data=#{data.inspect}"
      data || []
    end

    def self.get_feedback_job user_id, joblist=[]

      jobs=joblist.kind_of?(Array) ? joblist.join(',') : joblist

      get_data("jobstat:feedback_job:#{user_id}:#{jobs}",
        URI("http://graphit.parallel.ru:8123/api/feedback-job?user=#{user_id}&cluster=lomonosov-2&job_id=#{jobs}")
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

    def self.load_rules
      rules={}
      begin
        File.open("engines/jobstat/config/rules-plus.json", "r") { |file|
          rules=JSON.load(file)
        }
      rescue
      end
      rules
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
