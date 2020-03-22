module Sessions
  module ReportProject
    if Sessions.link?(:project)
      extend ActiveSupport::Concern
      included do
        octo_use(:project_class, :core, 'Project')
        belongs_to :project, class_name: project_class_to_s, foreign_key: :project_id
      end

      def block_project
        # Sessions::MailerWorker.perform_async(:postdated_report_on_project, id)
        project.block! unless project.blocked? or project.finished? or project.cancelled?
      end

      def close_project!
        Sessions::MailerWorker.perform_async(:project_failed_session, id)
        project.block!
      end
    end
  end
end
