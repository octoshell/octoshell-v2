module Jobstat
  class Admin::StatsController < Admin::ApplicationController
    def by_project

      @search = Core::Project.search(params[:q])
      # @project_kinds = @search.result(distinct: true).page(params[:page])


      n_h = 'EXTRACT(EPOCH FROM jobstat_jobs.end_time - jobstat_jobs.start_time)
      / 3600 * jobstat_jobs.num_nodes'
      @projects = Core::Project.select("core_projects.*, SUM(#{n_h}) AS n_h, COUNT(jobstat_jobs.id)")
                   .left_joins(members: :jobs)
                   .group('core_projects.id')
                   .where('jobstat_jobs.submit_time > ?', DateTime.new(2023, 1, 1))
    end
  end
end
