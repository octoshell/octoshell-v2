module FakeMainApp
  extend ::Octoface
  octo_configure do
    add(:user_class) { User } # теперь во всех модулях доступен report_class
    add_ability(:manage, :users, 'superadmins') #Если абилки нет, то она создаётся
    add_controller_ability(:manage, :users, 'admin/users') #В указанных контроллерах используется :manage :reports
    add_ability(:manage, :groups, 'superadmins') #Если абилки нет, то она создаётся
    add_controller_ability(:manage, :groups, 'admin/groups') #В указанных контроллерах используется :manage :reports
    add_ability(:manage, :options, 'superadmins') #Если абилки нет, то она создаётся

  end
end

Face::MyMenu.items_for(:user_submenu) do
  add_item('profile', t('user_submenu.profile'), main_app.profile_path, 'profiles',
           'core/employments', 'core/organizations')
end

Face::MyMenu.items_for(:admin_submenu) do
  add_item_if_may('users', t('admin_submenu.users'),
                  main_app.admin_users_path,
                  'admin/users')

  add_item_if_may('groups', t('admin_submenu.groups'),
                  main_app.admin_groups_path,
                  'admin/groups')

  if User.superadmins.include? current_user
    add_item('sidekiq', t("admin_submenu.sidekiq"), main_app.admin_sidekiq_web_path)
    add_item('emails', t("admin_submenu.emails"), main_app.rails_email_preview_path, %r{admin/emails})
    add_item('journal', t("admin_submenu.journal"), '/admin/journal', %r{admin/journal})
  end

  if can? :manage, :options
    add_item('options', t("admin_submenu.options"),
                        main_app.admin_options_categories_path,
                        %r{admin/options})
  end



                  # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.sidekiq"),
                  #                                   url: main_app.admin_sidekiq_web_path})) if User.superadmins.include? current_user

end
