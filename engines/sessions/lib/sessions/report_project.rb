module Sessions
  module ReportProject
    if ExternalLink.link?(:project)
      extend ActiveSupport::Concern
      included do
        belongs_to :project, class_name: "Core::Project", foreign_key: :project_id
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
