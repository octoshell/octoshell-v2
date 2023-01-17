module Perf
  class Job < ::ApplicationRecord
    self.table_name = "jobstat_jobs"
    belongs_to :member, class_name: 'Core::Member', foreign_key: 'login',
                        primary_key: 'login'
    class << self

      def submitted_in(start_date, finish_date)
        where(submit_time: start_date..finish_date)
      end

      def joins_projects_in_session(session_id)
        joins(member: { project: :projects_in_sessions })
          # .where(sessions_projects_in_sessions: { session_id: session_id })
      end

      def for_projects_in_session(start_date, finish_date, session_id)
        # submitted_in(start_date, finish_date)
          joins_projects_in_session(session_id)
      end

      def project_id_in_period(from, to)
        where('jobstat_jobs.created_at >= ? AND  jobstat_jobs.created_at <= ?',
              from, to).select(
                <<-SQL
          DISTINCT COALESCE(core_projects.id,
            CAST(substring(substring(object from  'project_id: [0-9]*\\n') from
            '[0-9][0-9]*' ) AS INT)) AS p_id
                SQL
              ).joins(
                <<-SQL
          LEFT OUTER JOIN "core_members" ON "core_members"."login" = "jobstat_jobs"."login"
          LEFT OUTER JOIN "core_projects" ON "core_projects"."id" = "core_members"."project_id"
                SQL
              ).joins(
                <<-SQL
          LEFT JOIN versions ON core_members.id IS NULL AND
            versions.item_type = 'Core::Member' AND versions.object IS NOT NULL AND
            versions.object LIKE CONCAT('%login: ', jobstat_jobs.login, '%\n')
                SQL
              )
      end


      def unknown_logins(from, to)
      # en =  DateTime.new(2022, 1, 1)
      sql = where('jobstat_jobs.created_at >= ? AND  jobstat_jobs.created_at <= ?',
          from, to).select(
          <<-SQL
          jobstat_jobs.*, core_projects.id AS p_id,
            CAST(substring(substring(object from  'project_id: [0-9]*\\n') from
            '[0-9][0-9]*' ) AS INT) AS c_id

          SQL
        ).joins(
          <<-SQL
          LEFT OUTER JOIN "core_members" ON "core_members"."login" = "jobstat_jobs"."login"
          LEFT OUTER JOIN "core_projects" ON "core_projects"."id" = "core_members"."project_id"
          SQL
        ).joins(
          <<-SQL
          LEFT JOIN versions ON core_members.id IS NULL AND
            versions.item_type = 'Core::Member' AND versions.object IS NOT NULL AND
            versions.object LIKE CONCAT('%login: ', jobstat_jobs.login, '%\n')
          SQL
        ).to_sql

        exec_query("SELECT * from (#{sql}) AS a
        where a.p_id IS NULL and a.c_id IS  NULL AND a.login != 'root'")

      end

      def exec_query(*args)

        sql = if args[0].is_a? Symbol
                send(*args)
              elsif args[0].is_a? String
                args[0]
              elsif args[0].nil?
                all.to_sql
              end
        connection.exec_query(sql).to_a
      end

    end

  end
end
