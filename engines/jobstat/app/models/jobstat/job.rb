module Jobstat
  class Job < ActiveRecord::Base
    include JobHelper

    def get_performance
      cpu_user = FloatDatum.where(job_id: id, name: "cpu_user").take
      instructions = FloatDatum.where(job_id: id, name: "instructions").take
      gpu_load = FloatDatum.where(job_id: id, name: "gpu_load").take
      loadavg = FloatDatum.where(job_id: id, name: "loadavg").take
      ipc = FloatDatum.where(job_id: id, name: "ipc").take
      ib_rcv_data = FloatDatum.where(job_id: id, name: "ib_rcv_data").take
      ib_xmit_data = FloatDatum.where(job_id: id, name: "ib_xmit_data").take

      data = { cpu_user: if !cpu_user.nil? then cpu_user.value else nil end,
        instructions: if !instructions.nil? then instructions.value else nil end,
        gpu_load: if !gpu_load.nil? then gpu_load.value else nil end,
        loadavg: if !loadavg.nil? then loadavg.value else nil end,
        ipc: if !ipc.nil? then ipc.value else nil end,
        ib_rcv_data: if !ib_rcv_data.nil? then ib_rcv_data.value else nil end,
        ib_xmit_data: if !ib_xmit_data.nil? then ib_xmit_data.value else nil end,
      }

      unless data[:ib_rcv_data].nil? then data[:ib_rcv_data] /= 1024 * 1024 end
      unless data[:ib_xmit_data].nil? then data[:ib_xmit_data] /= 1024 * 1024 end

      return data
    end

    def get_tags
      StringDatum.where(job_id: id, name: "tag").pluck(:value)
    end

    def get_ranking
      performance = get_performance

      {
          cpu_user: get_cpu_user_ranking(performance[:cpu_user]),
          instructions: get_instructions_ranking(performance[:instructions]),
          gpu_load: get_gpu_load_ranking(performance[:gpu_load]),
          loadavg: get_loadavg_ranking(performance[:loadavg], cluster),
          ipc: get_ipc_ranking(performance[:ipc]),
          ib_xmit_data: get_ib_xmit_data_ranking(performance[:ib_xmit_data]),
          ib_rcv_data: get_ib_rcv_data_ranking(performance[:ib_rcv_data]),
      }
    end

    def get_thresholds_conditions
      get_tags & Conditions::THRESHOLDS_CONDITIONS.keys
    end
  
    def get_primary_conditions
      get_tags & Conditions::PRIMARY_CONDITIONS.keys
    end

    def get_smart_conditions
      get_tags & Conditions::SMART_CONDITIONS.keys
    end
  end
end
