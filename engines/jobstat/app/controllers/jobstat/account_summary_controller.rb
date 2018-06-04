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
      @jobs = @jobs.select('EXTRACT( hours from SUM(num_nodes * (end_time - start_time))) as sum, count(*) as count, cluster, partition, state')
      @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)

      @data = {}

      @jobs.each do |job|
        cluster_data = @data.fetch(job.cluster, {})
        partition_data = cluster_data.fetch(job.partition, {})

        partition_data[job.state] = [job.count, job.sum]
        cluster_data[job.partition] = partition_data

        @data[job.cluster] = cluster_data
      end

      @queue_settings = {
        "lomonosov-2" => {
          "compute" => [14, 1],
          "low_io" => [14, 1],
          "compute_prio" => [14, 1],
          "test" => [14, 1],
          "pascal" => [12, 2],
        },
        "lomonosov-1" => {
          "regular-4" => [8, 0],
          "regular-6" => [12, 0],
          "hdd-4" => [8, 0],
          "hdd-6" => [12, 0],
          "test" => [8, 0],
          "gpu" => [8, 2],
          "gputest" => [8, 2],
        }
      }

      @total_data = {}

      @jobs.each do |job|
        val = @total_data.fetch(job.cluster, [0, 0, 0])

        begin
          val[0] += job.count
        rescue Exception
        end

        begin
          val[1] += job.sum * @queue_settings[job.cluster][job.partition][0]
        rescue Exception
        end

        begin
          val[2] += job.sum * @queue_settings[job.cluster][job.partition][1]
        rescue Exception
        end
        @total_data[job.cluster] = val
      end
    end
  end
end
