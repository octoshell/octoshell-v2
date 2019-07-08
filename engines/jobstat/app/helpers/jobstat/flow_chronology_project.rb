module Jobstat
    module FlowChronologyProject
        def chronology_projects(groupped_jobs, logins, login2project, dates, sorted_projects_by_runs, sorted_projects_by_resources)
            # prepare source for `project` histograms
            project_source = {}
            logins.each do |login|
                project_id = login2project[login] 
                project_source[project_id] = {}
                dates.each do |date|
                    project_source[project_id][date] = []
                end
            end

            groupped_jobs.each do |date, jobs|
                jobs.each do |job|
                    project_id = login2project[job.login]
                    project_source[project_id][date] += [job]
                end
            end

            # calculate project y params
            project_source_runs = {}
            project_source_resources = {}

            project_source.each do |project_id, source|
                project_source_runs[project_id] = {}
                project_source_resources[project_id] = {}

                source.each do |date, jobs|
                    project_source_runs[project_id][date] = jobs.count
                    if jobs.count == 0 
                        project_source_resources[project_id][date] = 0
                    else
                        project_source_resources[project_id][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end  
                end
            end

            # prepare project histogram data
            project_runs = []
            project_runs_other = {}
            project_source_runs.each do |project_id, values|
                if sorted_projects_by_runs.include?(project_id)
                    project_runs += [{
                        "label" => "Project id: #{project_id}",
                        "color" => color("Project id: #{project_id}"),
                        "group" => "",
                        "units" => "",
                        "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if project_runs_other.empty?
                        project_runs_other = values
                    else
                        values.each do |x, y|
                            project_runs_other[x] += y
                        end
                    end
                end
            end

            unless project_runs_other.empty?
                project_runs += [{
                "label" => "Other",
                "color" => color("Other"),
                "group" => "",
                "units" => "",
                "values" => project_runs_other.map { |k,v| {"x":k, "y":v}}
                }]
            end

            project_resources = []
            project_resources_other = {}
            project_source_resources.each do |project_id, values|
                if sorted_projects_by_resources.include?(project_id)
                    project_resources += [{
                        "label" => "Project id: #{project_id}",
                        "color" => color("Project id: #{project_id}"),
                        "group" => "",
                        "units" => "",
                        "values" => values.map { |k,v| {"x":k, "y":v}}
                    }]
                else
                    if project_resources_other.empty?
                        project_resources_other = values
                    else
                        values.each do |x, y|
                            project_resources_other[x] += y
                        end
                    end
                end
            end

            unless project_resources_other.empty?
                project_resources += [{
                    "label" => "Other",
                    "color" => color("Other"),
                    "group" => "",
                    "units" => "",
                    "values" => project_resources_other.map { |k,v| {"x":k, "y":v}}
                }]
            end

            return project_runs, project_resources
        end
    end
end