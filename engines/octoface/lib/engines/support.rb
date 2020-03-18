module Support
  extend Octoface
  octo_configure :support do
    add_ability(:manage, :tickets, 'superadmins', 'support')
    # add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
  end
end
