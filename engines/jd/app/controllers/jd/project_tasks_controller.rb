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
      @available_accounts = []
      @available_projects.each do |_, value|
        @available_accounts += value
      end

      @systems = @@systems
      @allowed_accounts = @available_accounts
      @t_from = nil
      @t_to = nil
      @partitions = ""
      @state = ""

      @jobs = {}

      if request.post?
        begin
          @t_from = Time.parse(params["request"].fetch("start_date")).to_i
          @t_to = Time.parse(params["request"].fetch("end_date")).to_i

          selected_accounts = params.fetch("selected_accounts")
          @allowed_accounts = selected_accounts & @available_accounts # filter accounts to avoid forgery

          @partitions = params.fetch("partitions")
          @state = params.fetch("state")

          @@systems.each do |system_name, system_url|
            print "jd: #{system_name} task_table query ms:", Benchmark.ms {
              data = query_stat_service(system_url + "/api/job_table/common" \
                , @allowed_accounts.join(","), @partitions.join(","), @state, @t_from, @t_to)
              @jobs[system_name] = data.take(100)
            }
          end
        rescue KeyError
          # skip bad params
        end
      end
      render :show_table
    end
  end
end
