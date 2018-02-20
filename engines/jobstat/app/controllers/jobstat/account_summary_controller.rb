require_dependency "jobstat/application_controller"

module Jobstat
  class AccountSummaryController < ApplicationController
    before_filter :require_login
    rescue_from MayMay::Unauthorized, with: :not_authorized

    def show
      year = Time.new.year
      defaults = {:start_time => "01.01.#{year - 1}",
                  :end_time => "01.01.#{year}",
                  :involved_logins => [],
                  :owned_logins => []
      }

      fill_owned_logins()
      fill_involved_logins()

      @params = defaults.merge(params.symbolize_keys)

      query_logins = (@params[:involved_logins] | @params[:owned_logins]) & (@involved_logins | @owned_logins)

      @jobs = Job.where "start_time > ? AND end_time < ?",
                        DateTime.parse(@params[:start_time]),
                        DateTime.parse(@params[:end_time])

      @jobs = @jobs.where(login: query_logins)
      @jobs = @jobs.select('SUM(num_cores * (end_time - start_time)), count(*), cluster, partition, state')
      @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)
    end

  end
end
