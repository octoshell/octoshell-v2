module Sessions
  extend Octoface
  octo_configure :sessions do
    add_ability(:manage, :reports, 'superadmins', 'experts')
    add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
    add_ability(:manage, :sessions, 'superadmins', 'experts')
    add_controller_ability(:manage, :sessions, 'admin/sessions',
                           'admin/surveys',
                           'admin/report_submit_denial_reasons',
                           'admin/projects')

    add_routes do
      mount Sessions::Engine, :at => "/sessions"
    end
    after_init do
      Sessions.user_class = '::User'
      Face::MyMenu.items_for(:user_submenu) do
        sessions_warning = current_user.warning_surveys.exists? ||
                           current_user.warning_reports.exists?
        sessions_title = if sessions_warning
                          t("user_submenu.sessions_warning.html").html_safe
                         else
                          t("user_submenu.sessions")
                         end
        add_item('sessions', sessions_title, sessions.reports_path, 'sessions/reports', 'sessions/user_surveys')
      end

      Face::MyMenu.items_for(:admin_submenu) do
        add_item_if_may('reports', t("admin_submenu.reports"), sessions.admin_reports_path, 'sessions/admin/reports')
        add_item_if_may('sessions', t("admin_submenu.sessions"), sessions.admin_sessions_path, 'sessions/admin/sessions', 'sessions/admin/surveys')
        add_item_if_may('report_submit_denial_reasons', t("admin_submenu.report_submit_denial_reasons"),
                         sessions.admin_report_submit_denial_reasons_path, 'sessions/admin/report_submit_denial_reasons')
      end
    end
  end

end
