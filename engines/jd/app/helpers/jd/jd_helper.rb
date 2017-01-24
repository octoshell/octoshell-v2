module Jd
  module JdHelper
    GOOD='jd_good_value_style'
    MEH='jd_meh_value_style'
    BAD='jd_bad_value_style'
    WHAT='jd_what_value_style'

    def get_sensor_color(sensor, value)
      if value.nil?
        return WHAT
      end

      case sensor
      when "cpu_user", "gpu_load", "gpu_mem_load"
        case value
        when 0..20
          return BAD
        when 20..80
          return MEH
        when 80..100
          return GOOD
        end

      when "cpu_flops"
        case value
        when 0..1e7
          return BAD
        when 1e7..1e8
          return MEH
        when 1e8..1e20
          return GOOD
        end

      when "cpu_perf_l1d_repl", "llc_miss"
        case value
        when 1e7..1e20
          return BAD
        when 1e5..1e7
          return MEH
        when 0..1e7
          return GOOD
        end

      when "mem_load", "mem_store"
        case value
        when 0..1e6
          return BAD
        when 1e6..1e8
          return MEH
        when 1e8..1e20
          return GOOD
        end

      when "ib_rcv_data", "ib_xmit_data"
        case value
        when 0..1e6
          return BAD
        when 1e6..1e7
          return MEH
        when 1e7..1e20
          return GOOD
        end

      when "ib_rcv_pckts", "ib_xmit_pckts"
        case value
        when 0..1e3
          return BAD
        when 1e3..1e5
          return MEH
        when 1e5..1e20
          return GOOD
        end

      when "loadavg"
        case value
        when 0..2
          return BAD
        when 2..7
          return MEH
        when 7..17
          return GOOD
        when 17..1e20
          return BAD
        end

      when "cpu_nice", "cpu_system", "cpu_idle", "cpu_iowait"
        case value
        when 0..20
          return GOOD
        when 20..80
          return MEH
        when 80..1e20
          return BAD
        end

      when "cpu_irq", "cpu_soft_irq"
        case value
          when 50..1e20
            return BAD
          when 10..50
            return MEH
          when 0..10
            return GOOD
        end


      when "ib_avg_rcv_pckt_size", "ib_avg_xmit_pckt_size"
        case value
          when 200..500, 1000..2000
            return MEH
          when 500..1000
            return GOOD
          else
            return BAD
        end

      when "l1_to_l3_ratio", "l1_to_mem_ratio", "l3_to_mem_ratio"
        case value
          when 0..10
            return BAD
          when 10..20
            return MEH
          when 20..1e20
            return GOOD
        end
      end

      return WHAT
    end
  end
end
