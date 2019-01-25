# == Schema Information
#
# Table name: sessions_projects_in_sessions
#
#  id         :integer          not null, primary key
#  session_id :integer
#  project_id :integer
#

module Sessions
  class ProjectsInSession < ActiveRecord::Base
    belongs_to :project, class_name: "Core::Project"
    belongs_to :session

    after_create :involve_project_in_session

    private

    def involve_project_in_session
      session.create_report_and_surveys_for(project) if session.active?
    end
  end
end
