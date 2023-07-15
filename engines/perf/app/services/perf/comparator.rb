module Perf
  class Comparator
    MEMBERS = Core::Member.arel_table
    JOBS = Perf::Job.arel_table
    PROJECTS = Sessions::ProjectsInSession.arel_table
    attr_reader :relation

    def self.scope(method_name, *args, &block)
      define_method method_name, *args, &block
    end

    def self.selections
      hours = '(extract(epoch from (end_time - start_time))/ 3600)'
      {
        node_hours: "(sum((#{hours})*num_nodes))",
        jobs: "count(jobstat_jobs.id)"
      }
    end

    scope :join_members do |relation|
      relation.join(MEMBERS).on(JOBS[:login].eq(MEMBERS[:login]))
    end

    scope :join_sessions do |relation|
      relation.join(PROJECTS)
              .on(PROJECTS[:project_id].eq(MEMBERS[:project_id]))

    end

    def initialize(session_id)
      @relation = JOBS.where(JOBS[:state].not_in(%w[COMPLETETED RUNNING unknown]))
                      .where(JOBS[:cluster].eq('lomonosov-2'))
      join_members(@relation)
      join_sessions(@relation)
      finish_date = Sessions::Session.find(session_id).started_at
      if finish_date
        start_date = finish_date - 1.year
        @relation.where(JOBS[:submit_time].between(start_date..finish_date))
      end
      @relation.where(PROJECTS[:session_id].eq(session_id))

    end

    def by_jobs_in_days(id)
      date = Arel::Nodes::SqlLiteral.new('DATE(submit_time) AS  submit_date')
      jobs = Arel::Nodes::SqlLiteral.new('count(jobstat_jobs.id) AS jobs')

      @relation.project(date, jobs)
               .group(literal('submit_date'))
               .order(literal('submit_date'))
               .where(MEMBERS[:project_id].eq(id))
      self
    end

    def by_jobs_in_days_and_state(id)
      by_jobs_in_days(id)
      @relation.group(JOBS[:state]).project(JOBS[:state])
      self
    end



    def count_projects
      relation.project(MEMBERS[:project_id].count(true).as('count'))
      self
    end

    def selections
      self.class.selections
    end

    def final_selections
      selections.keys.map do |key|
        ["s_#{key}", "s_place_#{key}", "s_share_#{key}", "s_share_place_#{key}",
         "n_#{key}", "n_place_#{key}"]
      end.flatten + %w[id] + (@extra_selections || [])
    end

    def show_project_stat(states, order)
      group_and_select
      states = Array(states).select(&:present?)
      share_relation = @relation.clone
      share_relation.where(JOBS[:state].in(states)) if states.any?
      selections.each do |key, value|
        relation.project(row_number(value).as("place_#{key}"))
      end
      s = share_relation.as('s')
      n = relation.as('n')
      manager = Arel::SelectManager.new
      joined = manager.project(n[:id])
                      .from(n)
                      .join(s, Arel::Nodes::OuterJoin).on(s[:id].eq(n[:id]))

      selections.keys.each do |key|
        lit = row_number(coalesce_0("s.#{key}"))
        division = case_division_by_zero(s, n, key).to_sql
        share_lit = row_number(division)
        joined.project(lit.as("s_place_#{key}"))
              .project(rounded(coalesce_0("s.#{key}")).as("s_#{key}"),
                       rounded("n.#{key}").as("n_#{key}"))
              .project(rounded(division + ' * 100', 2).as("s_share_#{key}"))
              .project(share_lit.as("s_share_place_#{key}"))
              .project(n["place_#{key}"].as("n_place_#{key}"))

      end
      @relation = joined
      if order.present?
        @relation.order(Arel::Nodes::SqlLiteral.new(order).asc)
      end
      self


    end

    def brief_project_stat
      @extra_selections = %w[state]
      group_and_select
      state_relation = @relation.clone.project(JOBS[:state].as('state'))
                                .group(JOBS[:state])

      selections.each do |key, value|
        relation.project(row_number(value).as("place_#{key}"))
      end

      s = state_relation.as('s')
      n = relation.as('n')
      manager = Arel::SelectManager.new
      joined = manager.project(s[:id], s[:state])
                      .from(s)
                      .join(n).on(s[:id].eq(n[:id]))
      selections.keys.each do |key|

        lit = row_number("s.#{key}", true)
        division = case_division_by_zero(s, n, key).to_sql
        share_lit = row_number(division, true)
        joined.project(lit.as("s_place_#{key}"))
              .project(rounded("s.#{key}").as("s_#{key}"),
                       rounded("n.#{key}").as("n_#{key}"))
              .project(rounded(division + ' * 100', 2).as("s_share_#{key}"))
              .project(share_lit.as("s_share_place_#{key}"))
              .project(n["place_#{key}"].as("n_place_#{key}"))

      end
      @relation = joined
      self
    end

    def group
      @relation.group(MEMBERS[:project_id])
               .project(MEMBERS[:project_id].as('id'))
    end

    def group_and_select
      group
      selections.each do |key, value|
        @relation.project(
          Arel::Nodes::SqlLiteral.new("(CAST(#{value} AS decimal))").as(key.to_s)
        )
      end
    end

    def id_eq(id)
      r = @relation.as('r')
      @relation = Arel::SelectManager.new
      @relation.project(*final_selections.map { |k| r[k] })
               .from(r)
               .where(r[:id].eq(id))
      self
    end

    def execute
      ActiveRecord::Base.connection.exec_query(@relation.to_sql).to_a
    end



    def row_number(key, partition_by_state = false)
      partition = partition_by_state ? 'PARTITION BY state' : ''
      Arel::Nodes::SqlLiteral.new "row_number() OVER (#{partition}
      ORDER BY (#{key}) DESC)".gsub("\n", ' ')
    end

    def case_division_by_zero(s, n, key)
      Arel::Nodes::Case.new
                       .when(n[key].eq(0).or(n[key].eq(nil))).then(0)
                       .when(s[key].eq(0).or(s[key].eq(nil))).then(0)
                       .else(s[key] / n[key])

    end

    def coalesce_0(arg)
      "(coalesce(#{arg},0))"
    end

    def rounded(arg, times = 0)
      Arel::Nodes::SqlLiteral.new "ROUND(#{arg}, #{times})"
    end

    def literal(arg)
      Arel::Nodes::SqlLiteral.new(arg)
    end
  end
end
