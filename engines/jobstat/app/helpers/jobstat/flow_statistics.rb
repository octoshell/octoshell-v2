module Jobstat
    require "groupdate"
    
    module FlowStatistics
        def select_jobs(start_time, end_time, logins, clusters, states)
            jobs = Job.where("start_time > ? AND end_time < ?", start_time, end_time)
                        .where(:login => logins)
                        .where(:cluster => clusters)
            unless states.include?("ALL")
                jobs = jobs.where(:state => states)
            end
            return jobs
        end

        def group_jobs_by(jobs, group_param)
            groupped_jobs = jobs
            formatting = "%Y week %W"
            unless group_param.nil?
              case group_param
              when "День"
                formatting = "%Y.%m.%d"
                groupped_jobs = @filtered_jobs.group_by_day(&:submit_time)
              when "Неделя"
                formatting = "%Y week %W"
                groupped_jobs = @filtered_jobs.group_by_week(&:submit_time)
              when "Месяц"
                formatting = "%Y.%m"
                groupped_jobs = @filtered_jobs.group_by_month(&:submit_time)
              when "Год"
                formatting = "%Y"
                groupped_jobs = @filtered_jobs.group_by_year(&:submit_time)
              end
            end
            return groupped_jobs, formatting
        end

        def calculate_resources_used(job)
            time_end = Time.parse(job.end_time.to_s)
            time_start = Time.parse(job.start_time.to_s)
            time_diff = time_end.minus_with_coercion(time_start)
            time_hours = (time_diff / 3600).round
            return time_hours * job.num_cores
        end

        @@hash_colors = {}
        @@used_colors = []

        def color(key)
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

            if @@hash_colors.include?(key)
                return @@hash_colors[key]
            else                
                color = (colors - @@used_colors).sample
                @@hash_colors[key] = color
                @@used_colors += [color]
                return color
            end
        end
    end
end