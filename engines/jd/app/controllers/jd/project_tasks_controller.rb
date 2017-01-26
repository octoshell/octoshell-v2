require_dependency "jd/application_controller"

module Jd
  class ProjectTasksController < ApplicationController

    def query_stat_service(request_path, accounts, partitions, states, date_from, date_to)
      begin
        open(request_path + "?date_to=#{date_to}&date_from=#{date_from}&accounts=#{accounts}&states=#{states}&partitions=#{partitions}", :read_timeout => 10) do |io|
          data = JSON.parse(io.read)
          return data
        end
      rescue => e
        puts e
        # skip bad lines
        return []
      end
    end

    def show_table()
      @available_projects = get_available_projects()
      @available_accounts = []
      @available_projects.each do |_, value|
        @available_accounts += value
      end

      @clusters = @@clusters
      @allowed_accounts = []
      @t_from = nil
      @t_to = nil
      @partition = ""
      @state = ""

      @jobs = {}

      if request.post?
        begin
          puts request.params

          @t_from = Time.parse(params["request"].fetch("start_date")).to_i
          @t_to = Time.parse(params["request"].fetch("end_date")).to_i

          selected_accounts = params.fetch("selected_accounts")

          @allowed_accounts = selected_accounts & @available_accounts

          @partition = params.fetch("partition")
          @state = params.fetch("state")

          @@clusters.each do |cluster_name, cluster_url|
            data = query_stat_service(cluster_url + "/api/job_table/common" \
            , @allowed_accounts.join(","), @partition, @state, @t_from, @t_to)

            @jobs[cluster_name] = data
          end
        rescue KeyError
          # skip bad params
        end
      end
      render :show_table
    end
  end
end
