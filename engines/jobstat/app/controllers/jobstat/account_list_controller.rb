require_dependency "jobstat/application_controller"

module Jobstat
  class AccountListController < ApplicationController
    @@clusters_options = [['Lomonosov-1', "lomonosov-1"], ['Lomonosov-2', "lomonosov-2"]]

    @@states_options = [["All", "ALL"] \
        , ["Completed", "COMPLETED"] \
        , ["Failed", "FAILED"] \
        , ["Cancelled", "CANCELLED"] \
        , ["Timeout", "TIMEOUT"] \
        , ["Node failed", "NODE_FAIL"]]

    @@partitions_options = [["All", "ALL"] \
        , ["compute", "compute"] \
        , ["gpu", "gpu"] \
        , ["regular4", "regular4"] \
        , ["regular6", "regular6"] \
        , ["test", "test"] \
        , ["gputest", "gputest"] \
        , ["hdd4", "hdd4"] \
        , ["hdd6", "hdd6"] \
        , ["smp", "smp"]]

    def get_defaults()
      defaults = {"start_time" => Date.today.beginning_of_month.strftime("%d.%m.%Y") \
        , "end_time" => Date.today.strftime("%d.%m.%Y") \
        , "cluster" => "lomonosov-1" \
        , "states" => [] \
        , "partitions" => [] \
        , "involved_logins" => [] \
        , "owned_logins" => [] \
      } # ActiveRecord bugs out with empty array

      @clusters_options = @@clusters_options
      @states_options = @@states_options
      @partitions_options = @@partitions_options

      return defaults
    end

    def index
      fill_owned_logins()
      fill_involved_logins()
      @params = get_defaults().merge(params)

      query_logins = (@params["involved_logins"] | @params["owned_logins"]) & (@involved_logins | @owned_logins)

      if @params["states"].length == 0 \
        or @params["partitions"].length == 0 \
        or query_logins.length == 0
        @notice = "Choose all query parameters"
        @jobs = []
        return
      else
        @notice = nil
      end

      @jobs = Job.where("start_time > ? AND end_time < ?", @params["start_time"], @params["end_time"])

      @jobs = @jobs.where("cluster = ?", @params["cluster"])
      @jobs = @jobs.where("state IN (?)", @params["states"]) unless @params["states"].include?("ALL")
      @jobs = @jobs.where("partition IN (?)", @params["partitions"]) unless @params["partitions"].include?("ALL")

      @jobs = @jobs.where("login IN (?)", query_logins)

      @jobs = @jobs.limit(100)
    end
  end
end
