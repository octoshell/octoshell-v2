Sessions.user_class = "::User"
module Reports
  extend Octoface
  octo_configure do
    # add(:report_class) { Report }
    # add(:session_class) { Session }
    # add(:user_survey_class) { UserSurvey }
    # add_ability(:manage, :reports, 'superadmins', 'experts')
    # add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
    # add_ability(:manage, :sessions, 'superadmins', 'experts')
    # add_controller_ability(:manage, :sessions, 'admin/sessions', 'admin/surveys', 'admin/report_submit_denial_reasons')
    #
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :reports_engine)
    add_item(t("admin_submenu.reports_engine"),main_app.reports_path, 'reports/constructor')
  end
end
