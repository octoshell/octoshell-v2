require "ostruct"
module Jobstat
  class Admin::StatsController < Admin::ApplicationController
    before_action :octo_authorize!
    def by_project
      process_ransack_params
      @project_search = Core::Project.ransack(params[:q])
      @project_relation = @project_search.result(distinct: true)
      @job_search = Jobstat::Job.ransack(job_params)
      job_result = @job_search.result(distinct: true)
                              .where(cluster: 'lomonosov-2').finished
      apply_custom_search
      @projects = NodeHourCounter.for_projects(
        @project_relation,
        job_result
      ).preload([{ owner: [:profile] }, :organization, :organization_department])

      without_pagination :projects unless params[:csv]

      @project_partitions = NodeHourCounter.for_projects_and_partitions(@projects, job_result)
                                           .group_by do |row|
                                             row['project_id']
                                           end
      if params[:csv]
        send_csv
        return
      end
      @partitions = ["ai-cont", "compute", "compute_prio", "low_io", "nec",
                     "pascal", "pascal_prio", "phi", "service", "test", "volta1",
                     "volta1_prio", "volta2", "volta2_prio"]
    end

    private

    def project_class
      Octoface.role_class(:core, 'Project')
    end

    def send_csv
      partitions = @project_partitions.values.flatten.map(&:partition).uniq.sort
      csv_string = CSV.generate do |csv|
        csv << [
          'id', project_class.human_attribute_name(:title),
          project_class.human_attribute_name(:state),
          project_class.human_attribute_name(:owner),
          project_class.human_attribute_name(:organization),
          project_class.human_attribute_name(:organization_department),
          project_class.human_attribute_name(:created_at),
          t('jobstat.admin.stats.project_table.job_count'),
          t('jobstat.admin.stats.project_table.node_hours'),
          *partitions
        ]
        @projects.each do |project|
          csv << [
            project.id,
            project.title,
            project.human_state_name,
            project.owner.full_name,
            project&.organization&.name,
            project&.organization_department&.name,
            project&.created_at,
            project.job_count,
            project.node_hours&.round,
            *node_hours_for_partitions(project.id, partitions)
          ]
        end
      end
      send_data csv_string, filename: "project_node_hours-#{Date.today}.csv",
                            disposition: :attachment
    end

    def node_hours_for_partitions(project_id, partitions)
      project_partitions = (@project_partitions[project_id] || [])
      partitions.map do |partition|
        project_partitions.detect { |row| row.partition == partition }
                          &.node_hours&.round
      end
    end


    def join_queries
    { job_count_gteq: proc { |v| @project_relation = @project_relation.where('j.n_h >= ?', v) } }
    end

    def apply_custom_search
      @custom_search = OpenStruct.new(custom_search_params)
      custom_search_params.each do |key, value|
        next unless value.present?

        join_queries[key.to_sym].call(value)
      end
    end

    def custom_search_params
      ((params[:q] || {})[:custom_q] || {})
    end

    def job_params
      return { submit_time_gteq: DateTime.new(Date.current.year, 1, 1) } unless params[:q]

      params[:q][:job_q]
    end

    def process_ransack_params
      q = params[:q]
      return unless q

      sep = /[\s,;]+/
      %w[id_in id_not_in].each do |key|
        value = q[key]
        next unless value.present?

        if value =~ /^(\d+#{sep})*\d*$/
          q[key] = value.split(sep)
        else
          flash_message('error', t(".#{key}_error"))
        end
      end
    end

  end
end
