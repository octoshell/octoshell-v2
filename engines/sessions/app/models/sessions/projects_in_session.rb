# == Schema Information
#
# Table name: sessions_projects_in_sessions
#
#  id         :integer          not null, primary key
#  project_id :integer
#  session_id :integer
#
# Indexes
#
#  i_on_project_and_sessions_ids                      (session_id,project_id) UNIQUE
#  index_sessions_projects_in_sessions_on_project_id  (project_id)
#  index_sessions_projects_in_sessions_on_session_id  (session_id)
#

module Sessions
  class ProjectsInSession < ActiveRecord::Base

    has_paper_trail

    belongs_to :project, class_name: "Core::Project"
    belongs_to :session

    after_create :involve_project_in_session

    private

    def involve_project_in_session
      session.create_report_and_surveys_for(project) if session.active?
    end
  end
end
