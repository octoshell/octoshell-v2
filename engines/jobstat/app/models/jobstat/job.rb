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

      data = { cpu_user: if !cpu_user.nil? then cpu_user.value else nil end,
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
          ib_xmit_data_fs: get_ib_xmit_data_fs_ranking(performance[:ib_xmit_data_fs]),
          ib_rcv_data_fs: get_ib_rcv_data_fs_ranking(performance[:ib_rcv_data_fs]),
          ib_xmit_data_mpi: get_ib_xmit_data_mpi_ranking(performance[:ib_xmit_data_mpi]),
          ib_rcv_data_mpi: get_ib_rcv_data_mpi_ranking(performance[:ib_rcv_data_mpi]),
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
