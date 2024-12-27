module FakeMainApp
  extend Octoface
  octo_configure :main_app do
    add_ability(:manage, :users, 'superadmins')
    add_controller_ability(:manage, :users, 'admin/users')
    add_ability(:manage, :groups, 'superadmins')
    add_controller_ability(:manage, :groups, 'admin/groups')
    add_ability(:manage, :options, 'superadmins')
    add_controller_ability(:manage, :policies, 'admin/policies') # Для Policies
    add_ability(:manage, :policies, 'superadmins') # Права для Policies

    after_init do
      Face::MyMenu.items_for(:user_submenu) do
        add_item('profile', t('user_submenu.profile'), main_app.profile_path, 'profiles',
                 'core/employments', 'core/organizations')
      end

      Face::MyMenu.items_for(:admin_submenu) do
        add_item('users', t('admin_submenu.users'),
                 main_app.admin_users_path,
                 'admin/users')

        add_item_if_may('groups', t('admin_submenu.groups'),
                        main_app.admin_groups_path,
                        'admin/groups')

        add_item_if_may('policies', t('admin_submenu.policies'),
                        main_app.policies_path, 'admin/policies') # Пункт для Policies

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

        if Rails.env.development?
          add_item('letter_opener', 'Letter opener',
                    main_app.admin_letter_opener_web_path)
        end
      end
    end
  end
end