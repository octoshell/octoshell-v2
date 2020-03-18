module FakeMainApp
  extend ::Octoface
  octo_configure :main_app do
    add('User') # теперь во всех модулях доступен report_class
    add_ability(:manage, :users, 'superadmins') #Если абилки нет, то она создаётся
    add_controller_ability(:manage, :users, 'admin/users') #В указанных контроллерах используется :manage :reports
    add_ability(:manage, :groups, 'superadmins') #Если абилки нет, то она создаётся
    add_controller_ability(:manage, :groups, 'admin/groups') #В указанных контроллерах используется :manage :reports
    add_ability(:manage, :options, 'superadmins') #Если абилки нет, то она создаётся
  end
end
