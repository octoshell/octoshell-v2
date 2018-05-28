module Jobstat
  class Job < ActiveRecord::Base
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

    def get_cpu_user_ranking(value)
      if value.nil?
        ""
      elsif value < 20
        "low"
      elsif value < 80
        "average"
      else
        "good"
      end
    end

    def get_instructions_ranking(value)
      if value.nil?
        ""
      elsif value < 100000000
        "low"
      elsif value < 400000000
        "average"
      else
        "good"
      end
    end

    def get_loadavg_ranking(value)
      if value.nil?
        return ""
      end

      if cluster == "lomonosov-1"
        if value < 2
          "low"
        elsif value < 7
          "average"
        elsif value < 15
          "good"
        else
          "low"
        end
      elsif cluster == "lomonosov-2"
        if value < 2
          "low"
        elsif value < 7
          "average"
        elsif value < 29
          "good"
        else
          "low"
        end
      end
    end

    def get_ipc_ranking(value)
      if value.nil?
        return ""
      end

      if value < 0.5
        "low"
      elsif value < 1.0
        "average"
      else
        "good"
      end
    end

    def get_gpu_load_ranking(value)
      if value.nil?
        return ""
      end

      if value < 20
        "low"
      elsif value < 80
        "average"
      else
        "good"
      end
    end

    def get_ib_rcv_data_ranking(value)
      if value.nil?
        return ""
      end

      if value < 10
        "low"
      elsif value < 100
        "average"
      else
        "good"
      end
    end

    def get_ib_xmit_data_ranking(value)
      if value.nil?
        return ""
      end

      if value < 10
        "low"
      elsif value < 100
        "average"
      else
        "good"
      end
    end

    def get_ranking
      performance = get_performance

      {
          cpu_user: get_cpu_user_ranking(performance[:cpu_user]),
          instructions: get_instructions_ranking(performance[:instructions]),
          gpu_load: get_gpu_load_ranking(performance[:gpu_load]),
          loadavg: get_loadavg_ranking(performance[:loadavg]),
          ipc: get_ipc_ranking(performance[:ipc]),
          ib_xmit_data: get_ib_xmit_data_ranking(performance[:ib_xmit_data]),
          ib_rcv_data: get_ib_rcv_data_ranking(performance[:ib_rcv_data]),
      }
    end 
  end
end
