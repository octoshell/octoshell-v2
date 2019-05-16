module Jobstat
    module FlowChronologyLogin
        def chronology_login(groupped_jobs, logins, dates, sorted_logins_by_runs, sorted_logins_by_resources)
            # prepare source for `login` histograms
            login_source = {}
            logins.each do |login|
                login_source[login] = {}
                dates.each do |date|
                    login_source[login][date] = []
                end
            end

            groupped_jobs.each do |date, jobs|
                jobs.each do |job|
                    login_source[job.login][date] += [job]
                end
            end

            # calculate login y params
            login_source_runs = {}
            login_source_resources = {}

            login_source.each do |login, source|
                login_source_runs[login] = {}
                login_source_resources[login] = {}

                source.each do |date, jobs|
                    login_source_runs[login][date] = jobs.count
                    if jobs.count == 0 
                        login_source_resources[login][date] = 0
                    else
                        login_source_resources[login][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end          
                end
            end

            # prepare state histogram data
            login_runs = []
            login_runs_other = {}
            login_source_runs.each do |login, values|
                if sorted_logins_by_runs.include?(login)
                    login_runs += [{
                        "label" => login,
                        "color" => color(login),
                        "group" => "",
                        "units" => "",
                        "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if login_runs_other.empty?
                        login_runs_other = values
                    else
                        values.each do |x, y|
                            login_runs_other[x] += y
                        end
                    end
                end
            end

            unless login_runs_other.empty?
                login_runs += [{
                    "label" => "Other",
                    "color" => color("Other"),
                    "group" => "",
                    "units" => "",
                    "values" => login_runs_other.map { |k,v| {"x":k, "y":v}}
                }]
            end

            login_resources = []
            login_resources_other = {}
            login_source_resources.each do |login, values|
                if sorted_logins_by_resources.include?(login)
                    login_resources += [{
                            "label" => login,
                            "color" => color(login),
                            "group" => "",
                            "units" => "",
                            "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if login_resources_other.empty?
                        login_resources_other = values
                    else
                        values.each do |x, y|
                            login_resources_other[x] += y
                        end
                    end
                end
            end

            unless login_resources_other.empty?
                login_resources += [{
                    "label" => "Other",
                    "color" => color("Other"),
                    "group" => "",
                    "units" => "",
                    "values" => login_resources_other.map { |k,v| {"x":k, "y":v}}
                }]
            end

            return login_runs, login_resources
        end
    end
end