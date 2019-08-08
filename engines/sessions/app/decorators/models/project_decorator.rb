Core::Project.class_eval do
  has_many :reports, class_name: "Sessions::Report", inverse_of: :project

  has_many :projects_in_sessions, class_name: "Sessions::ProjectsInSession"
  has_many :sessions, through: :projects_in_sessions, class_name: "Sessions::Session"
end
