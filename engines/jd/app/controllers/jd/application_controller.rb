module Jd
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    protect_from_forgery with: :exception

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
    end

    @@systems = Rails.configuration.jd_systems

    def get_available_projects(user)
      # get hash with projects and logins for user
      # include all logins from owned projects and
      # only personal logins for other projects

      result = Hash.new { |hash, key| hash[key] = [] }

      projects_with_participation = user.projects.where.not(id: (user.owned_projects.pluck(:id) \
        | user.projects_with_invitation.pluck(:id))) # TODO ???

      user.owned_projects.each do |project|
        project.members.each do |member|
          result[project].push(member.login)
        end
      end

      projects_with_participation.each do |project|
        project.members.each do |member|
          if member.user_id == user.id
            result[project].push(member.login)
          end
        end
      end

      return result
    end

    def get_available_accounts(available_projects)
      available_accounts = []

      available_projects.each do |_, value|
        available_accounts += value
      end

      return available_accounts
    end

    def query_stat_service(request_path, account, t_from, t_to)
      # query stat service for 1 account statistics

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
      #query stat service for statistics of all listed accounts

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

    def compute_system_stat(user_stat)
      # compute aggregated user statistics for each system

      result = {"count" => 0, "cores_sec" => 0, "gpu_sec" => 0}

      user_stat.each do |metric, values|
        values.each do |partition, states|
          states.each do |state, number|
            result[metric] += number

            if partition.include?("gpu") and metric.include?("cores_sec")
              result["gpu_sec"] += number / 4 # 2 cards per node, TODO
            end
            if partition.include?("compute") and metric.include?("cores_sec")
              result["gpu_sec"] += number / 14 # 1 card per node, TODO
            end
          end
        end
      end

      return result
    end

    def compute_total_system_stat(system_stat)
      # add total statistics to aggregated system statistics

      result = {"count" => 0, "cores_sec" => 0, "gpu_sec" => 0}

      system_stat.each do |_, stats|
        stats.each do |key, value|
          result[key] += value
        end
      end

      system_stat["TOTAL"] = result
    end

    def get_users_stat(accounts, t_from, t_to)
      user_stat = {}

      @@systems.each do |system_name, system_url|
        user_stat[system_name] = {}

        print "jd: #{system_name} user_stat query ms: ", Benchmark.ms {
          user_stat[system_name]["count"] = get_accounts_stat(system_url + "/api/job_stat/jobs/count" \
                , accounts, t_from, t_to)
          user_stat[system_name]["cores_sec"] = get_accounts_stat(system_url + "/api/job_stat/cores_sec/sum" \
                , accounts, t_from, t_to)
        }
      end

      return user_stat
    end

    def get_system_stat(user_stat)
      system_stat = {}

      @@systems.each do |system_name, _|
        system_stat[system_name] = compute_system_stat(user_stat[system_name])
      end

      compute_total_system_stat(system_stat)

      return system_stat
    end
  end
end
