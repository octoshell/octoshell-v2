module Sessions
  module SessionProject
    def self.prepended(base)
      base.class_eval do
        octo_use(:project_class, :core, 'Project')
        has_many :projects_in_sessions
        has_many :involved_projects, class_name: project_class_to_s,
                                     source: :project,
                                     through: :projects_in_sessions
      end
    end

    # prepended do
    #   octo_use(:project_class, :core, 'Project')
    #   has_many :projects_in_sessions
    #   has_many :involved_projects, class_name: project_class_to_s,
    #                                source: :project,
    #                                through: :projects_in_sessions
    # end

    def create_reports_and_users_surveys
      super
      involved_projects.each do |project|
        create_report_and_surveys_for(project)
      end
    end

    def validate_reports_and_surveys
      reports.where(state: :assessed).select(&:failed?).map(&:close_project!)
      super
    end



    def create_report_and_surveys_for(project)
      project.reports.create!(session: self, author: project.owner)
      surveys_per_project = surveys.reject { |s| s.personal? }
      surveys_per_project.each do |survey|
        if survey.only_for_project_owners?
          project.owner.surveys.create!(session: self, survey: survey, project: project)
        else
          project.members.where(:project_access_state=>:allowed).each do |member|
            member.user.surveys.create!(session: self, survey: survey, project: project)
          end
        end
      end
    end

    def moderate_included_projects(selected_project_ids)
      exclude_projects_from_session(selected_project_ids)
      update(involved_project_ids: selected_project_ids)
      create_personal_user_surveys
    end

    def exclude_projects_from_session(selected_project_ids)
      excluded_project_ids = involved_project_ids.select do |project_id|
        !selected_project_ids.include? project_id
      end
      excluded_projects = ProjectsInSession.where(session: self).where(project_id: excluded_project_ids)
      excluded_projects.each { |ip| clear_report_and_surveys_for(ip.project) } if self.active?
      excluded_projects.destroy_all
    end

    def clear_report_and_surveys_for(project)
      project.reports.where(session: self).destroy_all
      project.members.where(:project_access_state=>:allowed).each do |member|
        member.user.surveys.where(session: self, project: project).destroy_all
      end
      # TODO Mailer: project is excluded from session.
      # Sessions::MailerWorker
    end
  end
end
