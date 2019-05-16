module Jobstat
    module FlowTopUsers
        def top_user_by_state(groupped_jobs, states, sorted_users_by_runs, sorted_users_by_resources)
            # ===
            # режим: количество запусков
            # ===
            top_user_state_source = {}
            states.each do |state|
                top_user_state_source[state] = {}
                sorted_users_by_runs.each do |user_id|
                    top_user_state_source[state][user_id] = []
                end
            end

            groupped_jobs.each do |user_id, jobs|
                jobs.each do |job|
                    unless top_user_state_source[job.state][user_id].nil?
                        top_user_state_source[job.state][user_id] += [job]
                    end
                end
            end

            top_user_state_source_runs = {}

            top_user_state_source.each do |state, source|
                top_user_state_source_runs[state] = {}
                source.each do |user_id, jobs|
                    top_user_state_source_runs[state][user_id] = jobs.count
                end
            end
            # ===

            # === 
            # режим: объем ресурсов
            # === 
            top_user_state_source = {}
            states.each do |state|
                top_user_state_source[state] = {}
                sorted_users_by_resources.each do |project_id|
                    top_user_state_source[state][project_id] = []
                end
            end

            groupped_jobs.each do |user_id, jobs|
                jobs.each do |job|
                    unless top_user_state_source[job.state][user_id].nil?
                        top_user_state_source[job.state][user_id] += [job]
                    end
                end
            end


            top_user_state_source_resources = {}

            top_user_state_source.each do |state, source|
                top_user_state_source_resources[state] = {}
                source.each do |user_id, jobs|
                    if jobs.count == 0 
                        top_user_state_source_resources[state][user_id] = 0
                    else
                        top_user_state_source_resources[state][user_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end
                end
            end
            # === 

            # === 
            # переводим в формат данных для гистограмм (топ пользователей по статусам)
            # === 
            top_user_state_runs = []
            top_user_state_source_runs.each do |state, values|
                top_user_state_runs += [{
                    "label" => state,
                    "color" => color(state),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end

            top_user_state_resources = []
            top_user_state_source_resources.each do |state, values|
                top_user_state_resources += [{
                    "label" => state,
                    "color" => color(state),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end
            # === 

            return top_user_state_runs, top_user_state_resources
        end

        def top_user_by_logins(groupped_jobs, logins, sorted_users_by_runs, sorted_users_by_resources, sorted_logins_by_runs, sorted_logins_by_resources)
            # ===
            # режим: количество запусков
            # ===
            top_user_login_source = {}

            logins.each do |login|
                top_user_login_source[login] = {}
                sorted_users_by_runs.each do |user_id|
                    top_user_login_source[login][user_id] = []
                end
            end

            groupped_jobs.each do |user_id, jobs|
                jobs.each do |job|
                    unless top_user_login_source[job.login][user_id].nil?
                        top_user_login_source[job.login][user_id] += [job]
                    end
                end
            end

            top_user_login_source_runs = {}

            top_user_login_source.each do |login, source|
                top_user_login_source_runs[login] = {}
                source.each do |user_id, jobs|
                    top_user_login_source_runs[login][user_id] = jobs.count
                end
            end
            # ===

            # === 
            # режим: объем ресурсов
            # ===
            top_user_login_source = {}

            logins.each do |login|
                top_user_login_source[login] = {}
                sorted_users_by_resources.each do |user_id|
                    top_user_login_source[login][user_id] = []
                end
            end

            groupped_jobs.each do |user_id, jobs|
                jobs.each do |job|
                    unless top_user_login_source[job.login][user_id].nil?
                        top_user_login_source[job.login][user_id] += [job]
                    end
                end
            end

            top_user_login_source_resources = {}

            top_user_login_source.each do |login, source|
                top_user_login_source_resources[login] = {}
                source.each do |user_id, jobs|
                    if jobs.count == 0 
                        top_user_login_source_resources[login][user_id] = 0
                    else
                        top_user_login_source_resources[login][user_id] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end
                end
            end
            # === 

            # === 
            # переводим в формат данных для гистограмм (топ пользователей по логинам)
            # === 
            top_user_login_runs = []
            top_user_login_runs_other = {}
            top_user_login_source_runs.each do |login, values|
                if sorted_logins_by_runs.include?(login)
                    top_user_login_runs += [{
                        "label" => login,
                        "color" => color(login),
                        "group" => "",
                        "units" => "",
                        "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if top_user_login_runs_other.empty?
                        top_user_login_runs_other = values
                    else
                        values.each do |x, y|
                            top_user_login_runs_other[x] += y
                        end
                    end
                end
            end

            unless top_user_login_runs_other.empty?
                top_user_login_runs += [{
                    "label" => "Other",
                    "color" => color("Other"),
                    "group" => "",
                    "units" => "",
                    "values" => top_user_login_runs_other.map { |k,v| {"x":k, "y":v}}
                }]
            end

            top_user_login_resources = []
            top_user_login_resources_other = {}
            top_user_login_source_resources.each do |login, values|
                if sorted_logins_by_resources.include?(login)
                    top_user_login_resources += [{
                        "label" => login,
                        "color" => color(login),
                        "group" => "",
                        "units" => "",
                        "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if top_user_login_resources_other.empty?
                        top_user_login_resources_other = values
                    else
                        values.each do |x, y|
                            top_user_login_resources_other[x] += y
                        end
                    end
                end
            end

            unless top_user_login_resources_other.empty?
                top_user_login_resources += [{
                    "label" => "Other",
                    "color" => color("Other"),
                    "group" => "",
                    "units" => "",
                    "values" => top_user_login_resources_other.map { |k,v| {"x":k, "y":v}}
                }]
            end
            # === 

            return top_user_login_runs, top_user_login_resources
        end
    end
end