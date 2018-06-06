module Jobstat
  module JobHelper
    def format_float_or_nil(value)
      if value.nil?
        ""
      else
        "%.2f" % value.round(2)
      end
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

    def get_loadavg_ranking(value, cluster)
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

  end
end
