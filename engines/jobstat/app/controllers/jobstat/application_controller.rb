module Jobstat
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    before_filter :require_login, :load_defaults, :just_test

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def just_test
      logger.info "user_id=#{current_user ? current_user.id : 'none'}"
    end

    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end


    def load_defaults
      #FIXME!
      #TODO: load defaults from file

      return if @PER_PAGE

      @PER_PAGE = 100

      lom1 = ClusterConfig.new("Ломоносов-1", "lomonosov-1")
      lom2 = ClusterConfig.new("Ломоносов-2", "lomonosov-2")

      @clusters = {"lomonosov-1" => lom1, "lomonosov-2" => lom2}

      slurm_states = {
        "COMPLETED" => "Completed",
        "FAILED" => "Failed",
        "CANCELLED" => "Cancelled",
        "TIMEOUT" => "Timeout",
        "NODE_FAIL" => "Node failed",
      }

      lom1.states = slurm_states
      lom2.states = slurm_states

      lom1.partitions = {
        "regular4" => {"cores" => 8, "gpus" => 0},
        "regular6" => {"cores" => 12, "gpus" => 0},
        "hdd4" => {"cores" => 8, "gpus" => 0},
        "hdd6" => {"cores" => 12, "gpus" => 0},
        "test" => {"cores" => 8, "gpus" => 0},
        "gpu" => {"cores" => 8, "gpus" => 2},
        "gputest" => {"cores" => 8, "gpus" => 2},
      }

      lom2.partitions = {
        "compute" => {"cores" => 14, "gpus" => 1},
        "low_io" => {"cores" => 14, "gpus" => 1},
        "compute_prio" => {"cores" => 14, "gpus" => 1},
        "test" => {"cores" => 14, "gpus" => 1},
        "pascal" => {"cores" => 12, "gpus" => 2},
      }

      @default_cluster = "lomonosov-2"

      @states_options = slurm_states.keys
      @partitions_options = lom1.partitions.keys + lom2.partitions.keys

    end

  end
end
