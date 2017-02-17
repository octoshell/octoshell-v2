require_dependency "jd/application_controller"
require 'benchmark'

module Jd
  class ProjectTasksController < ApplicationController

    def query_stat_service(request_path, accounts, partitions, states, date_from, date_to)
      #query stat service for job table information

      begin
        request = request_path + "?date_to=#{date_to}&date_from=#{date_from}&accounts=#{accounts}&states=#{states}&partitions=#{partitions}"
        open(request, :read_timeout => 10) do |io|
          data = JSON.parse(io.read)
          return data
        end
      rescue => e
        # skip bad lines
        return []
      end
    end

    def show_table()
      # controller for job_table page
      @available_projects = get_available_projects(current_user)
      @selected_accounts = get_available_accounts(@available_projects) # select all by default

      @systems = @@systems

      @user_stat = nil
      @system_stat = nil

      @t_from = nil
      @t_to = nil

      @partitions = ""
      @state = ""

      @jobs = {}

      render :show_table
    end

    def query_table()
      # controller for job_table page
      @available_projects = get_available_projects(current_user)
      @selected_accounts = params.fetch("selected_accounts") & get_available_accounts(@available_projects)

      @systems = @@systems

      @t_from = Time.strptime(params["request"].fetch("start_date"), "%Y-%m-%d").to_i rescue nil
      @t_to = Time.strptime(params["request"].fetch("end_date"), "%Y-%m-%d").to_i rescue nil

      @partitions = params.fetch("partitions", [""])
      @state = params.fetch("state", "")

      @jobs = {}

      if @partitions.length > 0
        @@systems.each do |system_name, system_url|
          print "jd: #{system_name} task_table query ms:", Benchmark.ms {
            data = query_stat_service(system_url + "/api/job_table/common" \
              , @selected_accounts.join(","), @partitions.join(","), @state, @t_from, @t_to)
            @jobs[system_name] = data.take(100)
          }
        end
      end

      render :show_table
    end

  end
end
