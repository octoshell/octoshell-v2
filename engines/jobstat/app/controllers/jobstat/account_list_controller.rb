require_dependency "jobstat/application_controller"

module Jobstat
  class AccountListController < ApplicationController
    include JobHelper

    before_filter :require_login

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def index
      fill_owned_logins
      fill_involved_logins
      @params = get_defaults.merge(params.symbolize_keys)

      query_logins = (@params[:involved_logins] | @params[:owned_logins]) & (@involved_logins | @owned_logins)

      @JobAnalysisController = JobAnalysisController

      if @params[:states].length == 0 or
          @params[:partitions].length == 0 or
          query_logins.length == 0

        @notice = "Choose all query parameters"
        @jobs = []
        return
      else
        @notice = nil
      end

      @jobs = get_jobs(@params, query_logins)
	  warn "Controller done!"
    end

    protected

    def get_defaults
      load_defaults unless @clusters_options

      {:start_time => Date.today.beginning_of_month.strftime("%d.%m.%Y"),
       :end_time => Date.today.strftime("%d.%m.%Y"),
       :cluster => @default_cluster,
       :states => [],
       :partitions => [],
       :involved_logins => [],
       :owned_logins => [],
      }
    end

    def get_jobs(params, query_logins)
      jobs = Job.where "start_time > ? AND end_time < ?",
                       DateTime.parse(params[:start_time]), DateTime.parse(params[:end_time])

	  warn "Get jobs 1"
      jobs = jobs.where(state: @params[:states]) unless params[:states].include?("ALL")
	  warn "Get jobs 2"
      jobs = jobs.where(partition: @params[:partitions]) unless params[:partitions].include?("ALL")
	  warn "Get jobs 3"

      jobs.where(login: query_logins, cluster: params[:cluster]).order(:drms_job_id).limit(100)
    end

    def load_defaults
      #FIXME!
      #TODO: load defaults from file
      @clusters_options = [
          ["Lomonosov-1", "lomonosov-1"],
          ["Lomonosov-2", "lomonosov-2"],
      ]

      @states_options = [["All", "ALL"],
                         ["Completed", "COMPLETED"],
                         ["Failed", "FAILED"],
                         ["Cancelled", "CANCELLED"],
                         ["Timeout", "TIMEOUT"],
                         ["Node failed", "NODE_FAIL"],
      ]

      @partitions_options = [["All", "ALL"],
                             ["compute", "compute"],
                             ["gpu", "gpu"],
                             ["regular4", "regular4"],
                             ["regular6", "regular6"],
                             ["test", "test"],
                             ["gputest", "gputest"],
                             ["hdd4", "hdd4"],
                             ["hdd6", "hdd6"],
                             ["smp", "smp"],
      ]

      @default_cluster = "lomonosov-1"
    end
  end
end
