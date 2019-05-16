module Jobstat
    module FlowChronologyState
        def chronology_state(groupped_jobs, stack_params, stack_key, dates)
            # prepare source for `state` histograms
            source = {}
            stack_params.each do |stack|
                source[stack] = {}
                dates.each do |date|
                    source[stack][date] = []
                end
            end

            groupped_jobs.each do |date, jobs|
                jobs.each do |job|
                    source[job[stack_key]][date] += [job]
                end
            end

            # calculate state y params
            runs_stat = {}
            resources_stat = {}

            source.each do |stack, source|
                runs_stat[stack] = {}
                resources_stat[stack] = {}

                source.each do |date, jobs|
                    runs_stat[stack][date] = jobs.count
                    if jobs.count == 0 
                        resources_stat[stack][date] = 0
                    else
                        resources_stat[stack][date] = jobs.map{|j| calculate_resources_used(j)}.reduce(:+)
                    end
                end
            end

            # prepare state histogram data
            runs = []
            runs_stat.each do |stack, values|
                runs += [{
                    "label" => stack,
                    "color" => color(stack),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end

            resources = []
            resources_stat.each do |stack, values|
                resources += [{
                    "label" => stack,
                    "color" => color(stack),
                    "group" => "",
                    "units" => "",
                    "values" => values.map { |k,v| {"x":k, "y":v}}
                }]
            end

            return runs, resources
        end
    end
end