require_dependency "jobstat/application_controller"
require "groupdate"

module Jobstat
  class AccountSummaryController < ApplicationController
    include JobHelper

    def download()
      data = params[:data]
      # section = params[:section]
      unless data.nil?
        File.open("/Users/mozharovsky/Desktop/Octoshell_files/test.json", "wb") { |file| file.puts JSON.pretty_generate(data) }
        file_path = "/Users/mozharovsky/Desktop/Octoshell_files/test.json"
        file_name = "test.json"

        send_file(
          file_path,
          filename: file_name,
          type: "application/json"
        )
      end
      # redirect_to "http://0.0.0.0:5000/jobstat/account/summary/show"
      # redirect_to :action => "show"
    end

    def calculate_resources_used(job)
      time_end = Time.parse(job.end_time.to_s)
      time_start = Time.parse(job.start_time.to_s)
      time_diff = time_end.minus_with_coercion(time_start)
      time_hours = (time_diff / 3600).round
      return time_hours * job.num_cores
    end

    def show
      colors = [
        "#f8f3f6", "#ffdead", "#ffd700", "#1b50c7", "#cdad00",
        "#383838", "#cd9b9b", "#eeeeee", "#0000ff", "#003366",
        "#065535", "#cd950c", "#6495ed", "#00cdcd", "#458b00",
        "#836fff", "#ff0000", "#ba55d3", "#8470ff", "#b22222",
        "#ee1289", "#698b69", "#cd6600", "#556b2f", "#cd3333",
        "#439ec6", "#ffd4e5", "#cd1076", "#ffe3a6", "#bb5e87",
        "#ab3669", "#8b3a62", "#4a412a", "#faebd7", "#b0e0e6",
        "#003300", "#022445", "#e8d5e0", "#bff88b", "#d3ffce", 
        "#bcfff1", "#ff7f11"
      ]

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

      @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
      # @expert_projects=get_expert_projects
      # @projects = @projects.merge(@expert_projects)

      #get_select_options_by_projects @projects
      #@owned_logins = get_owned_logins
      #@involved_logins = get_involved_logins

      @params = defaults.merge(params.symbolize_keys)
      @projects=get_all_projects # {project: [login1,...], prj2: [login2,...]}
      @logins=get_all_logins.flatten.uniq

      @project_hash = {}
      get_all_projects.each do |project, logins|
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
      @selected_jobs = Job.where "start_time > ? AND end_time < ?",
                                  start_time,
                                  end_time
      @selected_jobs = @selected_jobs.where(:login => @selected_logins)
      @selected_jobs = @selected_jobs.where(:cluster => @selected_clusters)
      @selected_jobs = @selected_jobs.where(state: @params[:states]) unless @params[:states].include?("ALL")

      @selected_jobs_states = @selected_jobs.pluck(:state).uniq

      @filtered_jobs = @selected_jobs.all.to_a

      # Apply granulation
      @formatting = "%Y week %W"
      granulation = @params[:granulation]
      unless granulation.nil?
        case granulation
        when "День"
          @formatting = "%Y.%m.%d"
          @filtered_jobs = @filtered_jobs.group_by_day(&:submit_time)
        when "Неделя"
          @formatting = "%Y week %W"
          @filtered_jobs = @filtered_jobs.group_by_week(&:submit_time)
        when "Месяц"
          @formatting = "%Y.%m"
          @filtered_jobs = @filtered_jobs.group_by_month(&:submit_time)
        when "Год"
          @formatting = "%Y"
          @filtered_jobs = @filtered_jobs.group_by_year(&:submit_time)
        end
      end
    
      @filtered_dates = @filtered_jobs.map{|d,j| d}

      # ========================
      # Хронология Статусов
      # ========================

      # prepare source for `state` histograms
      @state_source = {}
      @selected_jobs_states.each do |state|
        @state_source[state] = {}
        @filtered_dates.each do |date|
          @state_source[state][date] = []
        end
      end

      @filtered_jobs.each do |date, jobs|
        jobs.each do |job|
          @state_source[job.state][date] += [job]
        end
      end

      # calculate state y params
      @state_source_runs = {}
      @state_source_resources = {}

      @state_source.each do |state, source|
        @state_source_runs[state] = {}
        @state_source_resources[state] = {}

        source.each do |date, jobs|
          @state_source_runs[state][date] = jobs.count
          if jobs.count == 0 
            @state_source_resources[state][date] = 0
          else
            @state_source_resources[state][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end

      # prepare state histogram data
      @state_runs = []
      @state_source_runs.each do |state, values|
        @state_runs += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @state_resources = []
      @state_source_resources.each do |state, values|
        @state_resources += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end


      # ====
      # helper
      # ====
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
      # ==== 

      # =====
      # Сортировка топ проектов и логинов по количеству запусков / объему ресурсов
      # =====
      _top_stack = @stack_max_tops

      # топы логинов
      @_top_login_runs = @selected_jobs.group_by{|j| j.login}.sort_by{|login, jobs| -jobs.count}.map{|k,v|k}[0..._top_stack]
      @_top_login_resources = @selected_jobs.group_by{|j| j.login}.sort_by{|login, jobs|
        jobs.map{|j|
          -calculate_resources_used(j)
        }.reduce(:+)
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

      @_top_project_runs = @_top_project_runs.sort_by{|project, jobs| -jobs.count}.map{|k,v|k}[0..._top_stack]
      #@_top_project_resources = @_top_project_resources.sort_by{|project, jobs| -jobs.map{|j| -calculate_resources_used(j)}.reduce(:+)}.map{|k,v|k}[0..._top_stack]

      # =====

      # ========================
      # Хронология Логинов
      # ========================

      # prepare source for `login` histograms
      @login_source = {}
      @selected_logins.each do |login|
        @login_source[login] = {}
        @filtered_dates.each do |date|
          @login_source[login][date] = []
        end
      end

      @filtered_jobs.each do |date, jobs|
        jobs.each do |job|
          @login_source[job.login][date] += [job]
        end
      end

      # calculate login y params
      @login_source_runs = {}
      @login_source_resources = {}

      @login_source.each do |login, source|
        @login_source_runs[login] = {}
        @login_source_resources[login] = {}

        source.each do |date, jobs|
          @login_source_runs[login][date] = jobs.count
          if jobs.count == 0 
            @login_source_resources[login][date] = 0
          else
            @login_source_resources[login][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end          
        end
      end

      # prepare state histogram data
      @login_runs = []
      @login_runs_other = {}
      @login_source_runs.each do |login, values|
        if @_top_login_runs.include?(login)
          @login_runs += [{
            "label" => login,
            "color" => colors.sample,
            "group" => "",
            "units" => "",
            "values" => values.map { |k,v| {"x":k, "y":v}}
          }]
        else
          if @login_runs_other.empty?
            @login_runs_other = values
          else
            values.each do |x, y|
              @login_runs_other[x] += y
            end
          end
        end
      end

      unless @login_runs_other.empty?
        @login_runs += [{
          "label" => "Other",
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => @login_runs_other.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @login_resources = []
      @login_resources_other = {}
      @login_source_resources.each do |login, values|
        if @_top_login_resources.include?(login)
          @login_resources += [{
            "label" => login,
            "color" => colors.sample,
            "group" => "",
            "units" => "",
            "values" => values.map { |k,v| {"x":k, "y":v}}
          }]
        else
          if @login_resources_other.empty?
            @login_resources_other = values
          else
            values.each do |x, y|
              @login_resources_other[x] += y
            end
          end
        end
      end

      unless @login_resources_other.empty?
        @login_resources += [{
          "label" => "Other",
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => @login_resources_other.map { |k,v| {"x":k, "y":v}}
        }]
      end

      # ========================
      # Хронология Проектов
      # ========================

      # prepare source for `project` histograms
      @project_source = {}
      @selected_logins.each do |login|
        project_id = @login2project[login] 
        @project_source[project_id] = {}
        @filtered_dates.each do |date|
          @project_source[project_id][date] = []
        end
      end

      @filtered_jobs.each do |date, jobs|
        jobs.each do |job|
          project_id = @login2project[job.login]
          @project_source[project_id][date] += [job]
        end
      end

      # calculate project y params
      @project_source_runs = {}
      @project_source_resources = {}

      @project_source.each do |project_id, source|
        @project_source_runs[project_id] = {}
        @project_source_resources[project_id] = {}

        source.each do |date, jobs|
          @project_source_runs[project_id][date] = jobs.count
          if jobs.count == 0 
            @project_source_resources[project_id][date] = 0
          else
            @project_source_resources[project_id][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end  
        end
      end

      # prepare project histogram data
      @project_runs = []
      @project_runs_other = {}
      @project_source_runs.each do |project_id, values|
        if @_top_project_runs.include?(project_id)
          @project_runs += [{
            "label" => "Project id: #{project_id}",
            "color" => colors.sample,
            "group" => "",
            "units" => "",
            "values" => values.map { |k,v| {"x":k, "y":v}}
          }]
        else
          if @project_runs_other.empty?
            @project_runs_other = values
          else
            values.each do |x, y|
              @project_runs_other[x] += y
            end
          end
        end
      end

      unless @project_runs_other.empty?
        @project_runs += [{
          "label" => "Other",
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => @project_runs_other.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @project_resources = []
      @project_resources_other = {}
      @project_source_resources.each do |project_id, values|
        if @_top_project_resources.include?(project_id)
          @project_resources += [{
            "label" => "Project id: #{project_id}",
            "color" => colors.sample,
            "group" => "",
            "units" => "",
            "values" => values.map { |k,v| {"x":k, "y":v}}
          }]
        else
          if @project_resources_other.empty?
            @project_resources_other = values
          else
            values.each do |x, y|
              @project_resources_other[x] += y
            end
          end
        end
      end

      unless @project_resources_other.empty?
        @project_resources += [{
          "label" => "Other",
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => @project_resources_other.map { |k,v| {"x":k, "y":v}}
        }]
      end

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

      # =========
      # Топы проектов по статусам
      # =========

      # === 
      # режим: количество запусков
      # === 
      @top_project_state_source = {}
      @selected_jobs_states.each do |state|
        @top_project_state_source[state] = {}
        @selected_project_ids_runs.each do |project_id|
          @top_project_state_source[state][project_id] = []
        end
      end

      @top_project_jobs.each do |project_id, jobs|
        jobs.each do |job|
          unless @top_project_state_source[job.state][project_id].nil?
            @top_project_state_source[job.state][project_id] += [job]
          end
        end
      end

      @top_project_state_source_runs = {}

      @top_project_state_source.each do |state, source|
        @top_project_state_source_runs[state] = {}
        source.each do |project_id, jobs|
          @top_project_state_source_runs[state][project_id] = jobs.count
        end
      end
      # ===


      # === 
      # режим: объем ресурсов
      # === 
      @top_project_state_source = {}
      @selected_jobs_states.each do |state|
        @top_project_state_source[state] = {}
        @selected_project_ids_resources.each do |project_id|
          @top_project_state_source[state][project_id] = []
        end
      end

      @top_project_jobs.each do |project_id, jobs|
        jobs.each do |job|
          unless @top_project_state_source[job.state][project_id].nil?
            @top_project_state_source[job.state][project_id] += [job]
          end
        end
      end


      @top_project_state_source_resources = {}

      @top_project_state_source.each do |state, source|
        @top_project_state_source_resources[state] = {}
        source.each do |project_id, jobs|
          if jobs.count == 0 
            @top_project_state_source_resources[state][project_id] = 0
          else
            @top_project_state_source_resources[state][project_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end
      # === 

      # === 
      # переводим в формат данных для гистограмм (топ пользователей по статусам)
      # === 
      @top_project_state_runs = []
      @top_project_state_source_runs.each do |state, values|
        @top_project_state_runs += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @top_project_state_resources = []
      @top_project_state_source_resources.each do |state, values|
        @top_project_state_resources += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end
      # === 


      # ======
      # Топы проектов по логинам
      # ======

      # === 
      # режим: количество запусков
      # === 
      @top_project_login_source = {}

      @selected_logins.each do |login|
        @top_project_login_source[login] = {}
        @selected_project_ids_runs.each do |project_id|
          @top_project_login_source[login][project_id] = []
        end
      end

      @top_project_jobs.each do |project_id, jobs|
        jobs.each do |job|
          unless @top_project_login_source[job.login][project_id].nil?
            @top_project_login_source[job.login][project_id] += [job]
          end
        end
      end

      @top_project_login_source_runs = {}

      @top_project_login_source.each do |login, source|
        @top_project_login_source_runs[login] = {}
        source.each do |project_id, jobs|
          @top_project_login_source_runs[login][project_id] = jobs.count
        end
      end
      # ===


      # === 
      # режим: объем ресурсов
      # === 
      @top_project_login_source = {}

      @selected_logins.each do |login|
        @top_project_login_source[login] = {}
        @selected_project_ids_resources.each do |project_id|
          @top_project_login_source[login][project_id] = []
        end
      end

      @top_project_jobs.each do |project_id, jobs|
        jobs.each do |job|
          unless @top_project_login_source[job.login][project_id].nil?
            @top_project_login_source[job.login][project_id] += [job]
          end
        end
      end


      @top_project_login_source_resources = {}

      @top_project_login_source.each do |login, source|
        @top_project_login_source_resources[login] = {}
        source.each do |project_id, jobs|
          if jobs.count == 0 
            @top_project_login_source_resources[login][project_id] = 0
          else
            @top_project_login_source_resources[login][project_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end
      # === 

      # === 
      # переводим в формат данных для гистограмм (топ пользователей по статусам)
      # === 
      @top_project_login_runs = []
      @top_project_login_source_runs.each do |login, values|
        @top_project_login_runs += [{
          "label" => login,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @top_project_login_resources = []
      @top_project_login_source_resources.each do |login, values|
        @top_project_login_resources += [{
          "label" => login,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end
      # === 

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

      # === 
      # Топ логинов по статусам
      # === 

      # === 
      # режим: количество запусков
      # === 
      @top_login_state_source = {}
      @selected_jobs_states.each do |state|
        @top_login_state_source[state] = {}
        @selected_login_ids_runs.each do |login|
          @top_login_state_source[state][login] = []
        end
      end

      @top_login_jobs.each do |login, jobs|
        jobs.each do |job|
          unless @top_login_state_source[job.state][login].nil?
            @top_login_state_source[job.state][login] += [job]
          end
        end
      end

      @top_login_state_source_runs = {}

      @top_login_state_source.each do |state, source|
        @top_login_state_source_runs[state] = {}
        source.each do |login, jobs|
          @top_login_state_source_runs[state][login] = jobs.count
        end
      end
      # ===

      # === 
      # режим: объем ресурсов
      # === 
      @top_login_state_source = {}
      @selected_jobs_states.each do |state|
        @top_login_state_source[state] = {}
        @selected_login_ids_resources.each do |login|
          @top_login_state_source[state][login] = []
        end
      end

      @top_login_jobs.each do |login, jobs|
        jobs.each do |job|
          unless @top_login_state_source[job.state][login].nil?
            @top_login_state_source[job.state][login] += [job]
          end
        end
      end

      @top_login_state_source_resources = {}

      @top_login_state_source.each do |state, source|
        @top_login_state_source_resources[state] = {}
        source.each do |login, jobs|
          if jobs.count == 0
            @top_login_state_source_resources[state][login] = 0
          else
            @top_login_state_source_resources[state][login] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end
      # === 

      # === 
      # переводим в формат данных для гистограмм (топ пользователей по статусам)
      # === 
      @top_login_state_runs = []
      @top_login_state_source_runs.each do |state, values|
        @top_login_state_runs += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @top_login_state_resources = []
      @top_login_state_source_resources.each do |state, values|
        @top_login_state_resources += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end
      # === 

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

      # ===
      # режим: количество запусков
      # ===
      @top_user_state_source = {}
      @selected_jobs_states.each do |state|
        @top_user_state_source[state] = {}
        @selected_user_ids_runs.each do |user_id|
          @top_user_state_source[state][user_id] = []
        end
      end

      @top_user_jobs.each do |user_id, jobs|
        jobs.each do |job|
          unless @top_user_state_source[job.state][user_id].nil?
            @top_user_state_source[job.state][user_id] += [job]
          end
        end
      end

      @top_user_state_source_runs = {}

      @top_user_state_source.each do |state, source|
        @top_user_state_source_runs[state] = {}
        source.each do |user_id, jobs|
          @top_user_state_source_runs[state][user_id] = jobs.count
        end
      end
      # ===

      # === 
      # режим: объем ресурсов
      # === 
      @top_user_state_source = {}
      @selected_jobs_states.each do |state|
        @top_user_state_source[state] = {}
        @selected_user_ids_resources.each do |project_id|
          @top_user_state_source[state][project_id] = []
        end
      end

      @top_user_jobs.each do |user_id, jobs|
        jobs.each do |job|
          unless @top_user_state_source[job.state][user_id].nil?
            @top_user_state_source[job.state][user_id] += [job]
          end
        end
      end


      @top_user_state_source_resources = {}

      @top_user_state_source.each do |state, source|
        @top_user_state_source_resources[state] = {}
        source.each do |user_id, jobs|
          if jobs.count == 0 
            @top_user_state_source_resources[state][user_id] = 0
          else
            @top_user_state_source_resources[state][user_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end
      # === 

      # === 
      # переводим в формат данных для гистограмм (топ пользователей по статусам)
      # === 
      @top_user_state_runs = []
      @top_user_state_source_runs.each do |state, values|
        @top_user_state_runs += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @top_user_state_resources = []
      @top_user_state_source_resources.each do |state, values|
        @top_user_state_resources += [{
          "label" => state,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end
      # === 


      # ===========
      # Топ пользователей по логинам
      # ===========

      # ===
      # режим: количество запусков
      # ===
      @top_user_login_source = {}

      @selected_logins.each do |login|
        @top_user_login_source[login] = {}
        @selected_user_ids_runs.each do |user_id|
          @top_user_login_source[login][user_id] = []
        end
      end

      @top_user_jobs.each do |user_id, jobs|
        jobs.each do |job|
          unless @top_user_login_source[job.login][user_id].nil?
            @top_user_login_source[job.login][user_id] += [job]
          end
        end
      end

      @top_user_login_source_runs = {}

      @top_user_login_source.each do |login, source|
        @top_user_login_source_runs[login] = {}
        source.each do |user_id, jobs|
          @top_user_login_source_runs[login][user_id] = jobs.count
        end
      end
      # ===

      # === 
      # режим: объем ресурсов
      # ===
      @top_user_login_source = {}

      @selected_logins.each do |login|
        @top_user_login_source[login] = {}
        @selected_user_ids_resources.each do |user_id|
          @top_user_login_source[login][user_id] = []
        end
      end

      @top_user_jobs.each do |user_id, jobs|
        jobs.each do |job|
          unless @top_user_login_source[job.login][user_id].nil?
            @top_user_login_source[job.login][user_id] += [job]
          end
        end
      end

      @top_user_login_source_resources = {}

      @top_user_login_source.each do |login, source|
        @top_user_login_source_resources[login] = {}
        source.each do |user_id, jobs|
          if jobs.count == 0 
            @top_user_login_source_resources[login][user_id] = 0
          else
            @top_user_login_source_resources[login][user_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
          end
        end
      end
      # === 

      # === 
      # переводим в формат данных для гистограмм (топ пользователей по логинам)
      # === 
      @top_user_login_runs = []
      @top_user_login_source_runs.each do |login, values|
        @top_user_login_runs += [{
          "label" => login,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end

      @top_user_login_resources = []
      @top_user_login_source_resources.each do |login, values|
        @top_user_login_resources += [{
          "label" => login,
          "color" => colors.sample,
          "group" => "",
          "units" => "",
          "values" => values.map { |k,v| {"x":k, "y":v}}
        }]
      end
      # === 

#       # Apply granulation
#       @formatting = "%Y week %W"
#       granulation = @params[:granulation]
#       unless granulation.nil?
#         case granulation
#         when "День"
#           @formatting = "%Y.%m.%d"
#           @selected_jobs_by_time_logins = @selected_jobs.group_by { |x| x.start_time.strftime("%Y.%m.%d") + "::#{x.login}" }.sort
#           @selected_jobs_by_date = @selected_jobs.group_by { |x| x.start_time.strftime("%Y.%m.%d") }.sort

#           # группировка без пропусков
#           @selected_jobs_by_date = []
#           (start_time..end_time).each do |date|
#             jobs = @selected_jobs.where "start_time > ? AND start_time < ?", 
#                                         date.beginning_of_day, date.end_of_day
#             @selected_jobs_by_date += [[date.strftime(@formatting), jobs.to_a]]
#           end

#         when "Неделя"
#           @formatting = "%Y week %W"
#           @selected_jobs_by_time_logins = @selected_jobs.group_by { |x| x.start_time.strftime("%Y week %W") + "::#{x.login}" }.sort
#           @selected_jobs_by_date = @selected_jobs.group_by { |x| x.start_time.strftime("%Y week %W") }.sort

#           # группировка без пропусков
#           @selected_jobs_by_date = []
#           weeks = (start_time..end_time).select(&:monday?)
#           weeks.each do |date|
#             jobs = @selected_jobs.where "start_time > ? AND start_time < ?", 
#                                         date.beginning_of_week, date.end_of_week
#             @selected_jobs_by_date += [[date.strftime(@formatting), jobs.to_a]]
#           end

#         when "Месяц"
#           @formatting = "%Y.%m"
#           @selected_jobs_by_time_logins = @selected_jobs.group_by { |x| x.start_time.strftime("%Y.%m") + "::#{x.login}" }.sort
#           @selected_jobs_by_date = @selected_jobs.group_by { |x| x.start_time.strftime("%Y.%m") }.sort

#           # группировка без пропусков
#           @selected_jobs_by_date = []
#           months = (start_time..end_time).group_by(&:month).map { |_,v| v.first.beginning_of_month }
#           months.each do |date|
#             jobs = @selected_jobs.where "start_time > ? AND start_time < ?", 
#                                         date.beginning_of_month, date.end_of_month
#             @selected_jobs_by_date += [[date.strftime(@formatting), jobs.to_a]]
#           end

#         when "Год"
#           @formatting = "%Y"
#           @selected_jobs_by_time_logins = @selected_jobs.group_by { |x| x.start_time.strftime("%Y") + "::#{x.login}" }.sort
#           @selected_jobs_by_date = @selected_jobs.group_by { |x| x.start_time.strftime("%Y") }.sort

#           # группировка без пропусков
#           @selected_jobs_by_date = []
#           years = (start_time..end_time).group_by(&:year).map { |_,v| v.first.beginning_of_year }
#           years.each do |date|
#             jobs = @selected_jobs.where "start_time > ? AND start_time < ?", 
#                                         date.beginning_of_year, date.end_of_year
#             @selected_jobs_by_date += [[date.strftime(@formatting), jobs.to_a]]
#           end
#         end
#       end

#       def calculate_resources_used(job)
#         time_end = Time.parse(job.end_time.to_s)
#         time_start = Time.parse(job.start_time.to_s)
#         time_diff = time_end.minus_with_coercion(time_start)
#         time_hours = (time_diff / 3600).round
#         return time_hours * job.num_cores
#       end

#       def median(array)
#         if array.nil? || array.length == 0
#           return nil
#         end
#         sorted = array.sort
#         len = sorted.length
#         return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
#       end

#       # Common Statistics
#       @statistics_data1_run = @selected_jobs_by_date.map { |x| [x.first, x.last.length] }
#       @statistics_data1_res = @selected_jobs_by_date.map { |x| [x.first, x.last.map { |y| calculate_resources_used(y) }.sum] }
#       statistics_data1_run_values = @statistics_data1_run.map { |x| x.last }
#       statistics_data1_res_values = @statistics_data1_res.map { |x| x.last }

#       @statistics_data1_run_map = {
#         :min => statistics_data1_run_values.min.to_f,
#         :max => statistics_data1_run_values.max.to_f,
#         :mean => statistics_data1_run_values.inject(&:+).to_f / statistics_data1_run_values.length,
#         :median => median(statistics_data1_run_values),
#         :sum => statistics_data1_run_values.inject(&:+).to_f
#       }

#       @statistics_data1_res_map = {
#         :min => statistics_data1_res_values.min.to_f,
#         :max => statistics_data1_res_values.max.to_f,
#         :mean => statistics_data1_res_values.inject(&:+).to_f / statistics_data1_res_values.length,
#         :median => median(statistics_data1_res_values),
#         :sum => statistics_data1_res_values.inject(&:+).to_f
#       }


#       # Runs by status
#       @statistics_data2_states_default = @selected_jobs_states
#                                                 .map { |x| {x => 0} }
#                                                 .reduce Hash.new, :merge
#       @statistics_data2_states = @selected_jobs_by_date.map { |x| 
#         [
#           x.first, 
#           @statistics_data2_states_default.merge(
#             Hash.new(0).tap { 
#               |h| x.last.map { |job| job.state }.each { |word| h[word] += 1 } 
#             }
#           )
#         ] 
#       }
#       @statistics_data2_states2 = @selected_jobs_by_date.map { |x|  
#         { "date" => x.first }.merge(@statistics_data2_states_default)
#           .merge(
#             Hash.new(0).tap { 
#               |h| x.last.map { |job| job.state }.each { |word| h[word] += 1 } 
#             }
#           )
#       }

#       # Runs by logins
#       @statistics_data3_logins_default = @selected_logins
#                                                 .map { |x| {x => 0} }
#                                                 .reduce Hash.new, :merge
#       @statistics_data3_logins = @selected_jobs_by_date.map { |x| 
#         [
#           x.first,
#           @statistics_data3_logins_default.merge(
#             Hash.new(0).tap { 
#               |h| x.last.map { |job| job.login }.each { |word| h[word] += 1 } 
#             }
#           )
#         ] 
#       }
#       @params[:all_logins]=query_logins

#       # @all_logins=@all_logins=get_grp_select_options_by_projects @projects, query_logins
#       # query_logins = (@params[:all_logins] & @all_logins[0])

#       @jobs = Job.where "start_time > ? AND end_time < ?",
#                         DateTime.parse(@params[:start_time]),
#                         DateTime.parse(@params[:end_time])

#       @jobs = @jobs.where(login: query_logins)
#       @jobs = @jobs.select('EXTRACT( hours from SUM(num_nodes * (end_time - start_time))) as sum, count(*) as count, cluster, partition, state')
#       @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)
# # compresss data list to hash
#       @data = {}
#       @total_cluster_data = {}
#       @total_data = [0, 0, 0]

#       @cluster_by_name = Hash.new Core::Cluster.all.map { |c| [c.description, c] }
#       seed=Core::Partition.preload(:cluster).all.map { |p|
#         p.resources =~ /cores:(\d+)/
#         cores = $1.to_i
#         p.resources =~ /gpus:(\d+)/
#         gpus = $1.to_i
#         ["#{p.cluster.description}//#{p.name}", [cores,gpus]]
#       }
#       @statistics_data3_logins2 = @selected_jobs_by_date.map { |x| 
#         { "date" => x.first }.merge(@statistics_data3_logins_default).merge(
#           Hash.new(0).tap { 
#             |h| x.last.map { |job| job.login }.each { |word| h[word] += 1 } 
#           }
#         )
#       }

#       @statistics_data4_states_logins = @selected_jobs_by_time_logins.map { |x| 
#         [
#           x.first, 
#           @statistics_data2_states_default.merge(
#             Hash.new(0).tap { 
#               |h| x.last.map { |job| job.state }.each { |word| h[word] += 1 } 
#             }
#           )
#         ] 
#       }

#       # Top runs by logins
#       @selected_jobs_logins = @selected_jobs.group_by { |x| x.login }.sort
#       @statistics_data5_top_run = @selected_jobs_logins.map { |x| [x.first, x.last.length] }
#                                                        .sort_by { |x| -x.last }[0...@max_tops]

#       @statistics_data5_top_run_hash = []
#       @statistics_data5_top_run.each do |top_run|
#         @statistics_data5_top_run_hash += [
#           {
#             "login": top_run[0],
#             "count": top_run[1]
#           }
#         ]
#       end

#       # Top res by logins
#       @statistics_data6_top_res = @selected_jobs_logins.map { |x| [x.first, x.last.map { |y| calculate_resources_used(y) }.sum] }
#                                                        .sort_by { |x| -x.last }[0...@max_tops]
#       @statistics_data6_top_res_hash = []
#       @statistics_data6_top_res.each do |top_res|
#         @statistics_data6_top_res_hash += [
#           {
#             "login": top_res[0],
#             "count": top_res[1]
#           }
#         ]
#       end

#       # Tops x States/Logins
#       @selected_jobs_logins_states = @selected_jobs.group_by { |x| "#{x.login}_#{x.state}" }.sort
#       @statistics_data5_top_state = @selected_jobs_logins_states.map { |x| [x.first, x.last.length] }
#                                                                 .sort_by { |x| -x.last }
#       @statistics_data6_top_state = @selected_jobs_logins_states.map { |x| [x.first, x.last.map { |y| calculate_resources_used(y) }.sum] }
#                                                                 .sort_by { |x| -x.last }


#       # ====
#       # Prepare logins & login2id hash
#       # ====
#       @logins = get_all_logins.flatten
#       @login2id = {}
#       Core::Member.where(:login => @logins).each do |member|
#         @login2id[member.login] = member.email.split("@").first
#       end
#       # ====


#       # ====
#       # Top Run groupped by user
#       # ====
#       _top_run_hash = Hash.new({})
#       @statistics_data5_top_run_hash.each do |hash|
#         count = hash[:count]
#         login = hash[:login]
#         id = @login2id[login]
#         unless _top_run_hash.has_key?(id)
#           _top_run_hash[id] = {}
#         end
#         _top_run_hash[id][login] = count
#       end

#       @test1 = _top_run_hash
#       @top_run_by_user = []
#       _top_run_hash.each do |user_id, hash|
#         @top_run_by_user.append({ "user": user_id,  }.merge(hash))
#       end
#       # ====


#       # ====
#       # Top States groupped by user
#       # ====
#       _top_res_hash = Hash.new({})
#       @statistics_data6_top_res_hash.each do |hash|
#         count = hash[:count]
#         login = hash[:login]
#         id = @login2id[login]
#         unless _top_res_hash.has_key?(id)
#           _top_res_hash[id] = {}
#         end
#         _top_res_hash[id][login] = count
#       end

#       @top_res_by_user = []
#       _top_res_hash.each do |user_id, hash|
#         @top_res_by_user.append({ "user": user_id,  }.merge(hash))
#       end
#       # ====



#       # ====
#       # Top logins by state
#       # ====

#       @test3 = []
#       jobs = @selected_jobs.select(:id, :login, :state).where "start_time > ? AND start_time < ?", 
#                                   start_time, end_time
#       jobs = jobs.group_by { |j| j.login }
      

#       jobs.each do |login, job|
#         res = {"login": login}
#         job.each do |j|
#           unless res.include?(j.state)
#             res[j.state] = 0
#           else
#             res[j.state] += 1
#           end
#         end
#         @test3 += [res]
#       end

#       @top_logins_by_state = [] 
#       @test3.each do |hash|
#         res = {}
#         res["_total_"] = 0
#         hash.each do |k,v|
#           res[k] = v
#           if k != "login"
#              res["_total_"] += v.to_i
#           end
#         end
#         @top_logins_by_state += [res]
#       end

#       @top_logins_by_state = @top_logins_by_state.sort_by { |x| -x["_total_"] }[0...@max_tops]
#       @top_logins_by_state.each do |obj|
#         obj.delete("_total_")
#       end

#       @top_logins_by_state_keys = @selected_jobs_states
#       # =======

      

#       # ====
#       # Top projects by state
#       # ====

#       @login2project = {}
#       @all_projects = []
#       Core::Member.where(:login => @logins).each do |member|
#         project = Core::Project.where(:id => member.project_id).map(&:title).first
#         @login2project[member.login] = project
#         @all_projects += [project]
#       end
#       @all_projects = @all_projects.uniq


#       jobs = @selected_jobs.select(:id, :login, :state).where "start_time > ? AND start_time < ?", 
#                                     start_time, end_time
#       jobs = jobs.group_by { |j| @login2project[j.login] }
#       @test4 = jobs



#       @top_projects_by_states = []
#       @top_projects_by_states_keys = @selected_jobs_states

#       jobs.each do |project, job|
#         res = {"project": project}
#         res["_total_"] = 0
#         job.each do |j|
#           res["_total_"] += 1
#           unless res.include?(j.state)
#             res[j.state] = 0
#           else
#             res[j.state] += 1
#           end
#         end
#         @top_projects_by_states += [res]
#       end

#       @top_projects_by_states = @top_projects_by_states.sort_by { |x| -x["_total_"] }[0...@max_tops]
#       @top_projects_by_states.each do |project|
#         project.delete("_total_")
#       end

#       @top_projects_by_logins = []
#       @top_projects_by_logins_keys = @logins

#       jobs.each do |project, job|
#         res = {"project": project}
#         res["_total_"] = 0
#         job.each do |j|
#           res["_total_"] += 1
#           unless res.include?(j.login)
#             res[j.login] = 0
#           else
#             res[j.login] += 1
#           end
#         end
#         @top_projects_by_logins += [res]
#       end

#       @top_projects_by_logins = @top_projects_by_logins.sort_by { |x| -x["_total_"] }[0...@max_tops]
#       @top_projects_by_logins.each do |project|
#         project.delete("_total_")
#       end











#       @projects=get_all_projects #{project: [login1,...], prj2: [log3,...]}
#       @expert_projects=get_expert_projects

#       @projects = @projects.merge(@expert_projects)

#       @all_logins=get_grp_select_options_by_projects @projects
#       #@owned_logins = get_owned_logins
#       #@involved_logins = get_involved_logins

#       @params = defaults.merge(params.symbolize_keys)

#       query_logins = @projects.map{|_,login| login}.flatten.uniq
#       req_logins=(@params[:all_logins] || []).reject{|x| x==''}
#       unless req_logins.include?('ALL') || req_logins.length==0
#         query_logins = (req_logins & query_logins)
#       end
#       @params[:all_logins]=query_logins

#       #query_logins = (@params[:all_logins] & @all_logins[0])

#       @jobs = Job.where "start_time > ? AND end_time < ?",
#                         DateTime.parse(@params[:start_time]),
#                         DateTime.parse(@params[:end_time])

#       @jobs = @jobs.where(login: query_logins)
#       @jobs = @jobs.select('EXTRACT( hours from SUM(num_nodes * (end_time - start_time))) as sum, count(*) as count, cluster, partition, state')
#       @jobs = @jobs.group(:cluster, :partition, :state).order(:cluster, :partition, :state)
# # compresss data list to hash
#       @data = {}
#       @total_cluster_data = {}
#       @total_data = [0, 0, 0]

#       @cluster_by_name = Hash.new Core::Cluster.all.map { |c| [c.description, c] }
#       seed=Core::Partition.preload(:cluster).all.map { |p|
#         p.resources =~ /cores:(\d+)/
#         cores = $1.to_i
#         p.resources =~ /gpus:(\d+)/
#         gpus = $1.to_i
#         ["#{p.cluster.description}//#{p.name}", [cores,gpus]]
#       }
#       @cluster_part_by_name = Hash[seed]
#       @jobs.each do |job|
#         entry = [0,0,0]

#         begin
#           cluster = Core::Cluster.where(description: job.cluster).last
#           next if cluster.nil?
#           partition = Core::Partition.where(cluster: cluster, name: job.partition).last
#           next if partition.nil?
#           part="#{cluster.description}//#{partition.name}"
#           res=@cluster_part_by_name[part] || [0,0]

#           cluster_data = @data.fetch(cluster, {})
#           partition_data = cluster_data.fetch(job.partition, {})

#           entry = [job.count,
#             job.sum * res[0],
#             job.sum * res[1]]
#         rescue => e
#           Rails.logger.error("error in statistics for job: #{job.cluster} #{job.state} #{job.partition}: #{e.message}")
#           next
#         end

#         partition_data[job.state] = entry
#         cluster_data[job.partition] = partition_data
#         @data[cluster] = cluster_data

#         val = @total_cluster_data.fetch(cluster, [0, 0, 0])

#         @total_cluster_data[cluster] = [val, entry].transpose.map {|x| x.reduce(:+)}
#         @total_data = [@total_data, entry].transpose.map {|x| x.reduce(:+)}
#       end
    end
  end
end
