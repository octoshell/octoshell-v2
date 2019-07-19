Sessions.user_class = "::User"
module Sessions
  extend Octoface
  octo_configure do
    add(:report_class) { Report }
    add(:session_class) { Session }
    add(:user_survey_class) { UserSurvey }
    add_ability(:manage, :reports, 'superadmins', 'experts')
    add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
  end
end

Face::MyMenu.first_or_new(:user_submenu) do
   sessions_warning = current_user.warning_surveys.exists? ||
                      current_user.warning_reports.exists?
   sessions_title = if sessions_warning
                     t("user_submenu.sessions_warning.html").html_safe
                    else
                     t("user_submenu.sessions")
                    end
   add_item(sessions_title, sessions.reports_path, 'sessions/reports', 'sessions/user_surveys')
end
