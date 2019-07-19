module FakeMainApp
  extend ::Octoface
  octo_configure do
    add(:user_class) { User } # теперь во всех модулях доступен report_class
    # add_ability(:manage, :reports, 'superadmins', 'experts') #Если абилки нет, то она создаётся
    # add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects') #В указанных контроллерах используется :manage :reports
  end
end

Face::MyMenu.first_or_new(:user_submenu) do
  add_item(t('user_submenu.profile'), main_app.profile_path, 'profiles',
           'core/employments', 'core/organizations')
end
