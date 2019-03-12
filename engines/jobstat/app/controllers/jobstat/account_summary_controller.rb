require_dependency "jobstat/application_controller"

module Jobstat
  class AccountSummaryController < ApplicationController
    include JobHelper
    def show
      year = Time.new.year
      defaults = {:start_time => Date.today.strftime("%Y.01.01"),
                  :end_time => Date.today.strftime("%Y.%m.%d"),
                  :involved_logins => [],
                  :owned_logins => []
      }

      @extra_css=['jobstat/application'] #, 'jobstat/introjs.min']
      @extra_js=['jobstat/application'] #, 'jobstat/intro.min']

      @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      @expert_projects=get_expert_projects

      @projects = @projects.merge(@expert_projects)

      @all_logins=get_select_options_by_projects @projects
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins

      @params = defaults.merge(params.symbolize_keys)

      query_logins = @projects.map{|_,login| login}.flatten.uniq
      req_logins=(@params[:all_logins] || []).reject{|x| x==''}
      unless req_logins.include?('ALL') || req_logins.length==0
        query_logins = (req_logins & query_logins)
      end
      @params[:all_logins]=query_logins

      #query_logins = (@params[:all_logins] & @all_logins[0])

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

      @cluster_by_name = Hash.new Core::Cluster.all.map { |c| [c.description, c] }
      seed=Core::Partition.preload(:cluster).all.map { |p|
        p.resources =~ /cores:(\d+)/
        cores = $1.to_i
        p.resources =~ /gpus:(\d+)/
        gpus = $1.to_i
        ["#{p.cluster.description}//#{p.name}", [cores,gpus]]
      }
      @cluster_part_by_name = Hash[seed]
      @jobs.each do |job|
        entry = [0,0,0]

        begin
          cluster = Core::Cluster.where(description: job.cluster).last
          next if cluster.nil?
          partition = Core::Partition.where(cluster: cluster, name: job.partition).last
          next if partition.nil?
          part="#{cluster.description}//#{partition.name}"
          res=@cluster_part_by_name[part] || [0,0]

          cluster_data = @data.fetch(cluster, {})
          partition_data = cluster_data.fetch(job.partition, {})

          entry = [job.count,
            job.sum * res[0],
            job.sum * res[1]]
        rescue => e
          Rails.logger.error("error in statistics for job: #{job.cluster} #{job.state} #{job.partition}: #{e.message}")
          next
        end

        partition_data[job.state] = entry
        cluster_data[job.partition] = partition_data
        @data[cluster] = cluster_data

        val = @total_cluster_data.fetch(cluster, [0, 0, 0])

        @total_cluster_data[cluster] = [val, entry].transpose.map {|x| x.reduce(:+)}
        @total_data = [@total_data, entry].transpose.map {|x| x.reduce(:+)}
      end
    end
  end
end
