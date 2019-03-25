module Jobstat
  class ApplicationController < ::ApplicationController
    layout "layouts/application"

    before_filter :require_login, :load_defaults #, :journal_user

    def load_defaults
      #TODO: load defaults from file

      return if @PER_PAGE

      @PER_PAGE = 100

      # lom1 = ClusterConfig.new("Ломоносов-1", "lomonosov-1")
      # lom2 = ClusterConfig.new("Ломоносов-2", "lomonosov-2")

      # @clusters = {"lomonosov-1" => lom1, "lomonosov-2" => lom2}
      slurm_states = {
        "RUNNING" => "Running",
        "COMPLETED" => "Completed",
        "FAILED" => "Failed",
        "CANCELLED" => "Cancelled",
        "TIMEOUT" => "Timeout",
        "NODE_FAIL" => "Node failed",
      }

      @clusters = {}
      part_opt = []
      Core::Cluster.where(available_for_work: true).each{|c|
        #name=c.name_ru
        #if name.nil? || name==''
        #  name=c.name_en
        #end
        name=c.name
        @clusters[name]=ClusterConfig.new(name, c.description)
        @clusters[name].states=slurm_states
        part_opt << c.partitions.map { |p| p.name }
        #logger.warn "#{name}--#{c.description}: #{part_opt.inspect}"
        #logger.warn "===> #{@clusters.inspect}"
      }
      @partitions_options = [part_opt, 'ALL'].flatten.uniq

      # lom1.states = slurm_states
      # lom2.states = slurm_states

      # lom1.partitions = {
      #   "regular4" => {"cores" => 8, "gpus" => 0},
      #   "regular6" => {"cores" => 12, "gpus" => 0},
      #   "hdd4" => {"cores" => 8, "gpus" => 0},
      #   "hdd6" => {"cores" => 12, "gpus" => 0},
      #   "test" => {"cores" => 8, "gpus" => 0},
      #   "gpu" => {"cores" => 8, "gpus" => 2},
      #   "gputest" => {"cores" => 8, "gpus" => 2},
      # }

      # lom2.partitions = {
      #   "compute" => {"cores" => 14, "gpus" => 1},
      #   "low_io" => {"cores" => 14, "gpus" => 1},
      #   "compute_prio" => {"cores" => 14, "gpus" => 1},
      #   "test" => {"cores" => 14, "gpus" => 1},
      #   "pascal" => {"cores" => 12, "gpus" => 2},
      # }

      @default_cluster = Core::Cluster.last.description #"lomonosov-2"

      @states_options = slurm_states.keys
      #@partitions_options = Core::Cluster.where(available_for_work: true).map{|c|
      #  c.partitions.map{|p| p.name}
      #}.flatten.uniq
      #lom1.partitions.keys + lom2.partitions.keys

    end

  end
end
