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
