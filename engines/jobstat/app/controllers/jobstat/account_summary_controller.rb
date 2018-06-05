require_dependency "jobstat/application_controller"

module Jobstat
  class AccountSummaryController < ApplicationController
    def show
      year = Time.new.year
      defaults = {:start_time => "01.01.#{year - 1}",
                  :end_time => "01.01.#{year}",
                  :involved_logins => [],
                  :owned_logins => []
      }

      @owned_logins = get_owned_logins
      @involved_logins = get_involved_logins

      @params = defaults.merge(params.symbolize_keys)

      query_logins = (@params[:involved_logins] | @params[:owned_logins]) & (@involved_logins | @owned_logins)

      @jobs = Job.where "start_time > ? AND end_time < ?",
                        DateTime.parse(@params[:start_time]),
                        DateTime.parse(@params[:end_time])

      @jobs = @jobs.where(login: query_logins)
      @jobs = @jobs.select('EXTRACT( hours from SUM(num_nodes * (end_time - start_time))) as sum, count(*) as count, cluster, partition, state')
      @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)

# compresss data list to hash
      @data = {}
      @total_cluster_data = {}
      @total_data = [0, 0, 0]

      @skipped = 0

      @jobs.each do |job|
        ebtry = [0,0,0]

        begin
          cluster = @clusters[job.cluster]
          partition = cluster.partitions[job.partition]

          cluster_data = @data.fetch(job.cluster, {})
          partition_data = cluster_data.fetch(job.partition, {})

          entry = [job.count,
            job.sum * partition["cores"],
            job.sum * partition["gpus"]]
        rescue Exception
          @skipped +=1
        end

        partition_data[job.state] = entry
        cluster_data[job.partition] = partition_data
        @data[job.cluster] = cluster_data

        val = @total_cluster_data.fetch(cluster.id, [0, 0, 0])

        @total_cluster_data[job.cluster] = [val, entry].transpose.map {|x| x.reduce(:+)}
        @total_data = [@total_data, entry].transpose.map {|x| x.reduce(:+)}
      end
    end
  end
end
