module Jobstat
  module JobHelper
    @@tags = {
      "cls_communicative_volume" => "receive or transmitted data > 500MB/s",
      "cls_communicative_packets" => "receive or transmitted packets > 300k/s",
      "cls_sc_appropriate" => "high data transmission rate and fitting loadavg",
      "cls_not_communicative" => "multi-node job with low network activity",
      "cls_serial" => "single node, single process jobs",
      "cls_suspicious" => "low cpu load, low loadavg, low gpu load",
      "cls_data_intensive" => "high memory activity",
      "cls_gpu_pure" => "high gpu load, low cpu load",
      "cls_gpu_hybrid_good" => "high gpu load, high cpu load",
      "cls_single" => "single node jobs",
      "cls_locality_good" => "good l1 and not bad l23 or good l23 and not bad l1",
      "cls_locality_bad" => "bad l1 and not good l23 or bad l23 and not good l1",
      "cls_locality_weird" => "good l1 and bad l23 or good l23 and bad l1",
      "short" => "less than 15 minutes"
    }

    def format_float_or_nil(value)
      if value.nil?
        return ""
      else
        return "%.2f" % value.round(2)
      end
    end

    def get_ranking(job, job_perf)
      ranking = {}
      begin
        if job_perf[:cpu_user] < 20
          ranking[:cpu_user] = "low"
        elsif job_perf[:cpu_user] < 80
          ranking[:cpu_user] = "average"
        else
          ranking[:cpu_user] = "good"
        end

        if job.cluster == "lomonosov-1"
          if job_perf[:loadavg] < 2
            ranking[:loadavg] = "low"
          elsif job_perf[:loadavg] < 7
            ranking[:loadavg] = "average"
          elsif job_perf[:loadavg] < 29
            ranking[:loadavg] = "good"
          else
            ranking[:loadavg] = "low"
          end
        elsif job.cluster == "lomonosov-2"
          if job_perf[:loadavg] < 2
            ranking[:loadavg] = "low"
          elsif job_perf[:loadavg] < 7
            ranking[:loadavg] = "average"
          elsif job_perf[:loadavg] < 29
            ranking[:loadavg] = "good"
          else
            ranking[:loadavg] = "low"
          end
        end

        if job_perf[:gpu_load] < 20
          ranking[:gpu_load] = "low"
        elsif job_perf[:gpu_load] < 80
          ranking[:gpu_load] = "average"
        else
          ranking[:gpu_load] = "good"
        end

        if job_perf[:ib_rcv_data] < 10
          ranking[:ib_rcv_data] = "low"
        elsif job_perf[:ib_rcv_data] < 100
          ranking[:ib_rcv_data] = "average"
        else
          ranking[:ib_rcv_data] = "good"
        end

        if job_perf[:ib_xmit_data] < 10
          ranking[:ib_xmit_data] = "low"
        elsif job_perf[:ib_xmit_data] < 100
          ranking[:ib_xmit_data] = "average"
        else
          ranking[:ib_xmit_data] = "good"
        end

      rescue
      end

      return ranking
    end
  end
end
