module Sessions
  extend Octoface
  octo_configure :sessions do
    add('Report')
    add('Session')
    add('UserSurvey')
    add_ability(:manage, :reports, 'superadmins', 'experts')
    add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
    add_ability(:manage, :sessions, 'superadmins', 'experts')
    add_controller_ability(:manage, :sessions, 'admin/sessions',
                           'admin/surveys',
                           'admin/report_submit_denial_reasons',
                           'admin/projects')

  end
end
