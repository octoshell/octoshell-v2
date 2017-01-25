require_dependency "jd/application_controller"

module Jd
  class UserStatController < ApplicationController
    def query_stat_service(request_path, account, t_from, t_to)
      jobs = Hash.new { |hash, key| hash[key] = Hash.new {0} }

      begin
        open(request_path + "?t_from=#{t_from}&t_to=#{t_to}&account=#{account}&grouping=partition,state", :read_timeout => 10) do |io|

          header = true
          CSV.parse(io.read, col_sep: ',') do |row|
            begin
              if header
                header = false
                next
              end

              value = row[0]
              partition = row[1]
              state = row[2]

              jobs[partition][state] += value.to_i
            rescue => e
              puts e
              # skip bad lines
            end
          end
        end
      rescue => e
        puts e
        # open failed
      end

      return jobs
    end

    def get_accounts_stat(request_path, accounts, t_from, t_to)
      result = Hash.new { |hash, key| hash[key] = Hash.new {0} }

      accounts.each do |account|
        stat = query_stat_service(request_path, account, t_from, t_to)
        stat.each do |partition, states|
          states.each do |state, count|
            result[partition][state] += count
          end
        end
      end

      return result
    end

    def compute_cluster_stat(user_stat)
      result = {"count" => 0, "cores_sec" => 0, "gpu_sec" => 0}

      user_stat.each do |metric, values|
        values.each do |partition, states|
          states.each do |state, number|
            result[metric] += number

            if partition.include?("gpu") and metric.include?("cores_sec")
              result["gpu_sec"] += number / 4 # TODO
            end
          end
        end
      end

      return result
    end

    def show_table()
      @available_projects = get_available_projects()
      @available_accounts = []
      @available_projects.each do |_, value|
        @available_accounts += value
      end

      @clusters = @@clusters
      @user_stat = nil
      @allowed_accounts = []
      @t_from = nil
      @t_to = nil
      @cluster_stat = nil

      if request.post?
        begin
          puts request.params

          @t_from = Time.parse(params["request"].fetch("start_date")).to_i
          @t_to = Time.parse(params["request"].fetch("end_date")).to_i

          selected_accounts = params.fetch("selected_accounts")
          @allowed_accounts = selected_accounts & @available_accounts

          @user_stat = {}
          @cluster_stat = {}
          @@clusters.each do |cluster_name, cluster_url|
            @user_stat[cluster_name] = {}
            @user_stat[cluster_name]["count"] = get_accounts_stat(cluster_url + "/api/job_stat/jobs/count" \
              , @allowed_accounts, @t_from, @t_to)
            @user_stat[cluster_name]["cores_sec"] = get_accounts_stat(cluster_url + "/api/job_stat/cores_sec/sum" \
              , @allowed_accounts, @t_from, @t_to)

            @cluster_stat[cluster_name] = compute_cluster_stat(@user_stat[cluster_name])
          end
        rescue KeyError
          # skip bad params
        end
      end

      render :show_table
    end
  end
end
