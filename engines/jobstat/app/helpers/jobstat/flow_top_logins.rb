module Jobstat
    module FlowTopLogins
        def top_login_by_state(groupped_jobs, states, sorted_logins_by_runs, sorted_logins_by_resources)
            # === 
            # режим: количество запусков
            # === 
            top_login_state_source = {}
            states.each do |state|
                top_login_state_source[state] = {}
                sorted_logins_by_runs.each do |login|
                    top_login_state_source[state][login] = []
                end
            end

            groupped_jobs.each do |login, jobs|
                jobs.each do |job|
                    unless top_login_state_source[job.state][login].nil?
                        top_login_state_source[job.state][login] += [job]
                    end
                end
            end

            top_login_state_source_runs = {}

            top_login_state_source.each do |state, source|
                top_login_state_source_runs[state] = {}
                source.each do |login, jobs|
                    top_login_state_source_runs[state][login] = jobs.count
                end
            end
            # ===

            # === 
            # режим: объем ресурсов
            # === 
            top_login_state_source = {}
            states.each do |state|
                top_login_state_source[state] = {}
                sorted_logins_by_resources.each do |login|
                    top_login_state_source[state][login] = []
                end
            end

            groupped_jobs.each do |login, jobs|
                jobs.each do |job|
                    unless top_login_state_source[job.state][login].nil?
                        top_login_state_source[job.state][login] += [job]
                    end
                end
            end

            top_login_state_source_resources = {}

            top_login_state_source.each do |state, source|
                top_login_state_source_resources[state] = {}
                source.each do |login, jobs|
                    if jobs.count == 0
                        top_login_state_source_resources[state][login] = 0
                    else
                        top_login_state_source_resources[state][login] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end
                end
            end
            # === 

            # === 
            # переводим в формат данных для гистограмм (топ пользователей по статусам)
            # === 
            top_login_state_runs = []
            top_login_state_source_runs.each do |state, values|
                    top_login_state_runs += [{
                    "label" => state,
                    "color" => color(state),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end

            top_login_state_resources = []
            top_login_state_source_resources.each do |state, values|
                top_login_state_resources += [{
                    "label" => state,
                    "color" => color(state),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end
            # === 

            return top_login_state_runs, top_login_state_resources
        end
    end
end