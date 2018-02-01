require_dependency "jobstat/application_controller"

module Jobstat
  class AccountSummaryController < ApplicationController
    def show
      defaults = {"start_time" => Date.new(2017).strftime("%d.%m.%Y"),
                  "end_time" => Date.new(2018).strftime("%d.%m.%Y"),
                  "involved_logins" => [],
                  "owned_logins" => []
      }

      fill_owned_logins()
      fill_involved_logins()

      @params = defaults.merge(params)

      query_logins = (@params["involved_logins"] | @params["owned_logins"]) & (@involved_logins | @owned_logins)

      @jobs = Job.where("start_time > ? AND end_time < ?", @params["start_time"], @params["end_time"])

      @jobs = @jobs.where("login IN (?)", query_logins)
      @jobs = @jobs.select('SUM(num_cores * (end_time - start_time)), count(*), cluster, partition, state')
      @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)
    end
  end
end
