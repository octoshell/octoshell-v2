module Jobstat
  class Job < ActiveRecord::Base
    def get_performance
      {
          cpu_user: FloatDatum.where(job_id: id, name: "cpu_user").take.value,
          gpu_load: FloatDatum.where(job_id: id, name: "gpu_load").take.value,
          loadavg: FloatDatum.where(job_id: id, name: "loadavg").take.value,
          ib_rcv_data: FloatDatum.where(job_id: id, name: "ib_rcv_data").take.value,
          ib_xmit_data: FloatDatum.where(job_id: id, name: "ib_xmit_data").take.value,
      }
    end

    def get_tags
      StringDatum.where(job_id: id, name: "tag").pluck(:value)
    end

    def get_cpu_user_ranking(value)
      if value < 20
        "low"
      elsif value < 80
        return "average"
      else
        "good"
      end
    end

    def get_loadavg_ranking(value)
      if cluster == "lomonosov-1"
        if value < 2
          return "low"
        elsif value < 7
          return "average"
        elsif value < 29
          return "good"
        else
          return "low"
        end
      elsif cluster == "lomonosov-2"
        if value < 2
          return "low"
        elsif value < 7
          return "average"
        elsif value < 29
          return "good"
        else
          return "low"
        end
      end
    end

    def get_gpu_load_ranking(value)
      if value < 20
        "low"
      elsif value < 80
        return "average"
      else
        "good"
      end
    end

    def get_ib_rcv_data_ranking(value)
      if value < 10 * 1024 * 1024
        "low"
      elsif value < 100 * 1024 * 1024
        return "average"
      else
        "good"
      end
    end

    def get_ib_xmit_data_ranking(value)
      if value < 10 * 1024 * 1024
        "low"
      elsif value < 100 * 1024 * 1024
        return "average"
      else
        "good"
      end
    end

    def get_ranking
      performance = get_performance

      {
          cpu_user: get_cpu_user_ranking(performance[:cpu_user]),
          gpu_load: get_gpu_load_ranking(performance[:gpu_load]),
          loadavg: get_loadavg_ranking(performance[:loadavg]),
          ib_xmit_data: get_ib_xmit_data_ranking(performance[:ib_xmit_data]),
          ib_rcv_data: get_ib_rcv_data_ranking(performance[:ib_rcv_data]),
      }
    end
  end
end
