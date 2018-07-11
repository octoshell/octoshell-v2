require 'yaml/store'

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
      cpu_user = FloatDatum.where(job_id: id, name: "cpu_user").take
      instructions = FloatDatum.where(job_id: id, name: "instructions").take
      gpu_load = FloatDatum.where(job_id: id, name: "gpu_load").take
      loadavg = FloatDatum.where(job_id: id, name: "loadavg").take
      ipc = FloatDatum.where(job_id: id, name: "ipc").take
      ib_rcv_data_fs = FloatDatum.where(job_id: id, name: "ib_rcv_data_fs").take
      ib_xmit_data_fs = FloatDatum.where(job_id: id, name: "ib_xmit_data_fs").take
      ib_rcv_data_mpi = FloatDatum.where(job_id: id, name: "ib_rcv_data_mpi").take
      ib_xmit_data_mpi = FloatDatum.where(job_id: id, name: "ib_xmit_data_mpi").take

      data = {
        cpu_user: if !cpu_user.nil? then cpu_user.value else nil end,
        instructions: if !instructions.nil? then instructions.value else nil end,
        gpu_load: if !gpu_load.nil? then gpu_load.value else nil end,
        loadavg: if !loadavg.nil? then loadavg.value else nil end,
        ipc: if !ipc.nil? then ipc.value else nil end,
        ib_rcv_data_fs: if !ib_rcv_data_fs.nil? then ib_rcv_data_fs.value else nil end,
        ib_xmit_data_fs: if !ib_xmit_data_fs.nil? then ib_xmit_data_fs.value else nil end,
        ib_rcv_data_mpi: if !ib_rcv_data_mpi.nil? then ib_rcv_data_mpi.value else nil end,
        ib_xmit_data_mpi: if !ib_xmit_data_mpi.nil? then ib_xmit_data_mpi.value else nil end,
      }

      unless data[:ib_rcv_data_fs].nil? then data[:ib_rcv_data_fs] /= 1024 * 1024 end
      unless data[:ib_xmit_data_fs].nil? then data[:ib_xmit_data_fs] /= 1024 * 1024 end
      unless data[:ib_rcv_data_mpi].nil? then data[:ib_rcv_data_mpi] /= 1024 * 1024 end
      unless data[:ib_xmit_data_mpi].nil? then data[:ib_xmit_data_mpi] /= 1024 * 1024 end

      return data
    end


    def get_tags
      tags=StringDatum.where(job_id: id, name: "tag").pluck(:value)
    end

    def get_ranking
      performance = get_performance

      {
          cpu_user: get_cpu_user_ranking(performance[:cpu_user]),
          instructions: get_instructions_ranking(performance[:instructions]),
          gpu_load: get_gpu_load_ranking(performance[:gpu_load]),
          loadavg: get_loadavg_ranking(performance[:loadavg], cluster),
          ipc: get_ipc_ranking(performance[:ipc]),
          ib_xmit_data_fs: get_ib_xmit_data_fs_ranking(performance[:ib_xmit_data_fs]),
          ib_rcv_data_fs: get_ib_rcv_data_fs_ranking(performance[:ib_rcv_data_fs]),
          ib_xmit_data_mpi: get_ib_xmit_data_mpi_ranking(performance[:ib_xmit_data_mpi]),
          ib_rcv_data_mpi: get_ib_rcv_data_mpi_ranking(performance[:ib_rcv_data_mpi]),
      }
    end

    def slice(dict, vals)
      res = []
      vals.each do |val|
        begin
          res.push(dict.fetch(val))
        rescue KeyError
        end
      end
      res
    end

    def get_thresholds
      slice(Conditions.instance.thresholds, get_tags)
    end

    def get_classes
      slice(Conditions.instance.classes, get_tags)
    end

    def get_rules
      filters=get_filters
      tags=get_tags
      tags=tags - filters
      slice(Conditions.instance.rules, tags)
    end
  end

  def get_cached data

    Rails.cache.fetch(data) do
      result=yield
      cache_db.transaction do
        if result
          cache_db[data]=result
        else
          result=cache_db[data]
        end
      end
      result
    end
  end

  def cache_db
    return @@cache_db_singleton if @@cache_db_singleton

    @@cache_db_singleton=YAML::Store.new "engines/jobstat/cache.yaml"
  end

  def get_filters(user)
    user_id=user.id
    get_cached("jobstat:filters:#{user_id}") do
      #FIXME! move address to config
      uri="http://graphit.parallel.ru:8124/api/filters"
      Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https', 
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE,
                      :read_timeout => 5,
                      :opentimeout => 5,
                     ) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        #request.basic_auth 'username', 'password'

        response = http.request request

        if response.body.nil?
          nil
        else
          response.body.split ','
        end
      end      
    end
  end

  def post_filters(user,filters)
    user_id=user.id
    projects=get_involved_projects(user)
    accesses=projects.map{|p| p.accesses}
    uri="http://graphit.parallel.ru:8124/api/filters"
    Net::HTTP.start(uri.host, uri.port,
                      :use_ssl => uri.scheme == 'https', 
                      :verify_mode => OpenSSL::SSL::VERIFY_NONE,
                      :read_timeout => 5,
                      :opentimeout => 5,
                     ) do |http|
      request = Net::HTTP::post_form(
        uri.request_uri,
        user: user_id,
        #FIXME! title -> RNF id
        cluster: accesses.map{|a| a.cluster}.flatten.uniq.map { |c| c.title }.join(','),
        account: projects.map { |p| p.members.map { |m| m.login } }.flatten.uniq.join(','),
        filters: filters.join(','),
      )
      response = http.request request

      # return true if success
      response.code === Net::HTTPSuccess

      # FIXME! retry post later!

    end
  end


end
