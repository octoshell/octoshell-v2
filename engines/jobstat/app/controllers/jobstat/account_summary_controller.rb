require "groupdate"

module Jobstat
  class AccountSummaryController < ApplicationController
    include JobHelper
    include FlowStatistics,
            FlowChronologyState,
            FlowChronologyLogin,
            FlowChronologyProject,
            FlowTopProject,
            FlowTopLogins,
            FlowTopUsers

    def show
      year = Time.new.year
      all_value = "ALL"
      defaults = {
        :start_time => DateTime.now.beginning_of_month().strftime("%Y.%m.%d"),
        :end_time => DateTime.now.end_of_month().strftime("%Y.%m.%d"),
        :cluster => all_value,
        :states => all_value,
        :projects => all_value,
        :logins => all_value,
        :granulation => "Неделя",
        :involved_logins => [],
        :owned_logins => [],
        :max_tops => 20,
        :stack_max_tops => 10
      }

      @extra_css=['jobstat/application'] #, 'jobstat/introjs.min']
      @extra_js=['jobstat/application'] #, 'jobstat/intro.min']

      # !!! FIXME   adding 'true' argument returns ALL available projects (for admins/experts)
      #             use it for admin version
      @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      # @expert_projects=get_expert_projects
      # @projects = @projects.merge(@expert_projects)

      #get_select_options_by_projects @projects
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins
      params.permit!
      @params = defaults.merge(params.to_h.symbolize_keys)
      #@projects=get_all_projects # {project: [login1,...], prj2: [login2,...]}
      @logins=get_all_logins.flatten.uniq

      @project_hash = {}
      @projects.each do |project, logins|
        @project_hash["[id: #{project.id}] #{project.title}"] = project
      end

      query_logins = @projects.map{|_,login| login}.flatten.uniq
      req_logins=(@params[:all_logins] || []).reject{|x| x==''}
      unless req_logins.include?('ALL') || req_logins.length==0
        query_logins = (req_logins & query_logins)
      end

      # Set default max top-k value
      @max_tops = @params[:max_tops].to_i
      if @max_tops.nil?
        @max_tops = 20
      end

      # Set default max stack-top-k value
      @stack_max_tops = @params[:stack_max_tops].to_i
      if @stack_max_tops.nil?
        @stack_max_tops = 10
      end

      # Select projects
      @selected_projects = []
      proj = @params[:projects]
      unless proj.nil? || proj.length == 0
        if proj.include?(all_value)
          @selected_projects = @projects
        else
          proj = proj.map { |x| @project_hash[x] }.compact.map { |x| x.title }
          @selected_projects = @projects.select{|key| proj.include?(key.to_s)}
        end
      end

      # Select logins
      @selected_logins = []
      logins = @params[:logins]
      unless logins.nil? || logins.length == 0
        if logins.include?(all_value)
          @selected_logins = @selected_projects.map {|_, value| value}.flatten.uniq
        else
          @selected_logins = @logins.select {|key| logins.include?(key.to_s)}
        end
      end

      # Select clusters
      @selected_clusters = []
      clusters = @params[:cluster]
      unless clusters.nil? || clusters.length == 0
        if clusters.include?(all_value)
          @selected_clusters = Core::Cluster.all.map { |c| c.description }
        else
          @selected_clusters = Core::Cluster.all.map { |c| c.description }
                                                .select { |key| clusters.include?(key.to_s) }
        end
      end


      # Select jobs that satisfy the date interval
      start_time = DateTime.parse(@params[:start_time])
      end_time = DateTime.parse(@params[:end_time])

      @selected_jobs = select_jobs(start_time, end_time, @selected_logins, @selected_clusters, @params[:states])
      @selected_jobs_states = @selected_jobs.pluck(:state).uniq
      @filtered_jobs = @selected_jobs.all.to_a

      @formatting = "%Y week %W"
      @granulation = @params[:granulation]

      @filtered_jobs, @formatting = group_jobs_by(@selected_jobs, @granulation)
      @filtered_dates = @filtered_jobs.map{|d,j| d}

      # ===========
      # Конвертация из логина в проекты и пользователи
      # ===========
      @login2project = {}
      @selected_logins.each do |login|
        project_ids = Core::Member.where(login: login).pluck(:project_id)
        # project_titles = Core::Project.where(id: project_ids).pluck(:title)
        project_ids.each do |id|
          @login2project[login] = id
        end
      end

      @login2user = {}
      @selected_logins.each do |login|
        user_ids = Core::Member.where(login: login).pluck(:user_id)
        user_ids.each do |id|
          @login2user[login] = id
        end
      end
      # ===========

      # ===========
      # Сортировка топ проектов и логинов по количеству запусков / объему ресурсов
      # ===========
      _top_stack = @stack_max_tops

      # топы логинов
      @_top_login_runs = @selected_jobs.group_by{|j| j.login}.sort_by{|login, jobs|
        -jobs.count
      }.map{|k,v|
        k
      }[0..._top_stack]
      @_top_login_resources = @selected_jobs.group_by{|j| j.login}.sort_by{|login, jobs|
        jobs.map{|j|
          -calculate_resources_used(j)
        }.reduce(:+) || 0
      }.map{|k,v|k}[0..._top_stack]

      # топы проектов
      @_top_project_runs = {}
      @_top_project_resources = {}

      @login2project.each do |k, project_id|
        @_top_project_runs[project_id] = []
        @_top_project_resources[project_id] = []
      end

      @selected_jobs.each do |job|
        project_id = @login2project[job.login]
        @_top_project_runs[project_id] += [job]
        @_top_project_resources[project_id] += [job]
      end

      @_top_project_runs = @_top_project_runs.sort_by{|project, jobs|
        -jobs.count
      }.map{|k,v|
        k
      }[0..._top_stack]
      @_top_project_resources = @_top_project_resources.sort_by{|project, jobs|
        -(jobs.map{|j|
          -calculate_resources_used(j)
        }.reduce(:+) || 0)
      }.map{|k,v|
        k
      }[0..._top_stack]
      # ===========

      # ========================
      # Хронология Статусов
      # ========================
      @state_runs, @state_resources = chronology_state(@filtered_jobs, @selected_jobs_states, "state", @filtered_dates)
      # ========================

      # ========================
      # Хронология Логинов
      # ========================
      @login_runs, @login_resources = chronology_login(@filtered_jobs, @selected_logins, @filtered_dates, @_top_login_runs, @_top_login_resources)
      # ========================

      # ========================
      # Хронология Проектов
      # ========================
      @project_runs, @project_resources = chronology_projects(@filtered_jobs, @selected_logins, @login2project, @filtered_dates, @_top_project_runs, @_top_project_resources)
      # ========================

      # ========================
      # Топ Проектов
      # ========================

      # prepare jobs groupping by projects
      @top_project_jobs = {}
      @selected_logins.each do |login|
        project_id = "Project id: #{@login2project[login]}"
        @top_project_jobs[project_id] = []
      end

      @selected_jobs.each do |job|
        project_id = "Project id: #{@login2project[job.login]}"
        @top_project_jobs[project_id] += [job]
      end

      # select project keys (descending)
      @selected_project_ids_runs = @top_project_jobs.sort_by{|_,jobs| -jobs.count}.map{|k,v|k}[0...@max_tops]
      @selected_project_ids_resources = @top_project_jobs.sort_by{|p,jobs|
        res = jobs.map{|j|
          -calculate_resources_used(j)
        }
        res.reduce(:+) || 0
      }.map{
        |k,v| k
      }[0...@max_tops]

      # ===========
      # Топы проектов по статусам
      # ===========
      @top_project_state_runs, @top_project_state_resources = top_project_by_state(@top_project_jobs, @selected_jobs_states, @selected_project_ids_runs, @selected_project_ids_resources)
      # ===========

      # ===========
      # Топы проектов по логинам
      # ===========
      @top_project_login_runs, @top_project_login_resources = top_project_by_login(@top_project_jobs, @selected_logins, @selected_project_ids_runs, @selected_project_ids_resources, @_top_login_runs, @_top_login_resources)
      # ===========

      # ========================
      # Топ Логинов
      # ========================

      @top_login_jobs = {}
      @selected_logins.each do |login|
        @top_login_jobs[login] = []
      end

      @selected_jobs.each do |job|
        @top_login_jobs[job.login] += [job]
      end

      # select login keys (descending)
      @selected_login_ids_runs = @top_login_jobs.sort_by{|_,jobs| -jobs.count}.map{|k,v|k}[0...@max_tops]
      @selected_login_ids_resources = @top_login_jobs.sort_by{|_,jobs|
        jobs.map{|j|
          -calculate_resources_used(j)
        }.reduce(:+) || 0
      }.map{|k,v|
        k
      }[0...@max_tops]

      # ===========
      # Топ логинов по статусам
      # ===========
      @top_login_state_runs, @top_login_state_resources = top_login_by_state(@top_login_jobs, @selected_jobs_states, @selected_login_ids_runs, @selected_login_ids_resources)
      # ===========

      # ========================
      # Топ Пользователей
      # ========================

      # prepare jobs groupping by users
      @top_user_jobs = {}
      @selected_logins.each do |login|
        user_id = "User id: #{@login2user[login]}"
        @top_user_jobs[user_id] = []
      end

      @selected_jobs.each do |job|
        user_id = "User id: #{@login2user[job.login]}"
        @top_user_jobs[user_id] += [job]
      end

      # select user keys (descending)
      @selected_user_ids_runs = @top_user_jobs.sort_by{|user,jobs| -jobs.count}.map{|k,v|k}[0...@max_tops]
      @selected_user_ids_resources = @top_user_jobs.sort_by{|user,jobs|
        jobs.map{|j|
          -calculate_resources_used(j)
        }.reduce(:+) || 0
      }.map{|k,v|
        k
      }[0...@max_tops]

      # ===========
      # Топ пользователей по статусам
      # ===========
      @top_user_state_runs, @top_user_state_resources = top_user_by_state(@top_user_jobs, @selected_jobs_states, @selected_user_ids_runs, @selected_user_ids_resources)
      # ===========

      # ===========
      # Топ пользователей по логинам
      # ===========
      @top_user_login_runs, @top_user_login_resources = top_user_by_logins(@top_user_jobs, @selected_logins, @selected_user_ids_runs, @selected_user_ids_resources, @_top_login_runs, @_top_login_resources)
      # ===========


      #@projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      @expert_projects=get_expert_projects

      @projects = @projects.merge(@expert_projects)

      @all_logins=get_grp_select_options_by_projects @projects
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins

      @params = defaults.merge(params.to_h.symbolize_keys)

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
