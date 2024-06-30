module Jobstat
  class NodeHourCounter
    class << self


      def for_projects(job_relation, project_relation)
        project_relation.select('core_projects.*, j.n_h AS node_hours').joins(<<-SQL
          LEFT JOIN (#{aggregate_node_hours_by_project_id(job_relation)}) AS j
            ON core_projects.id = j.project_id
          SQL
                                                                             )
      end

      private

      def coalesce_project
        <<-SQL
         COALESCE(core_members.project_id,
          CAST(substring(substring(object from  'project_id: [0-9]*\\n') from
          '[0-9][0-9]*' ) AS INT))
        SQL
      end

      def aggregate_node_hours_by_project_id(job_relation)
        <<-SQL
          SELECT SUM(j.n_h) AS n_h, #{coalesce_project} AS project_id
          FROM (#{aggregate_node_hours_by_login(job_relation).to_sql}) AS j
          LEFT JOIN core_members ON core_members.login = j.login
          LEFT JOIN versions  ON core_members.project_id IS NULL AND
          versions.item_type = 'Core::Member' AND versions.object IS NOT NULL AND
          versions.object LIKE CONCAT('%login: ', j.login, '%\n')
          GROUP BY #{coalesce_project}
        SQL
      end

      def aggregate_node_hours_by_login(job_relation)
        job_relation.select("SUM(#{node_hours}) AS n_h, jobstat_jobs.login")
                    .group('jobstat_jobs.login')
      end

      def node_hours
        'EXTRACT(EPOCH FROM jobstat_jobs.end_time - jobstat_jobs.start_time)
        / 3600 * jobstat_jobs.num_nodes'
      end




    end
  end
end
