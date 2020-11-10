module Sessions
  module ReportProject
    def self.prepended(base)
      base.class_eval do
        octo_use(:project_class, :core, 'Project')
        belongs_to :project, class_name: project_class_to_s,
                             foreign_key: :project_id
      end
    end
    # prepended do
    #   octo_use(:project_class, :core, 'Project')
    #   belongs_to :project, class_name: project_class_to_s,
    #                        foreign_key: :project_id
    # end

    def notify_about_assess
      super
      return unless failed?

      block_project
    end

    def postdate_callback
      super
      block_project
    end

    def block_project
      project.block! unless project.blocked? || project.finished? ||
                            project.cancelled?
    end

    def close_project!
      Sessions::MailerWorker.perform_async(:project_failed_session, id)
      project.block!
    end
  end
end
