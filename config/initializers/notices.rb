module Core
  extend Octoface
  octo_configure do
    add_ability(:manage,  :notices, 'superadmins')
    add_ability(:manage,  Core::Notice, 'superadmins')
    add_ability(:destroy, :notices, 'superadmins') # <--- does not work
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :tickets)
    add_item('notices', t("core.notice.notices_menu"), core.admin_notices_path,
             %r{^notices})
  end
end

Face::MyMenu.items_for(:user_submenu) do
  add_item('notices', t("core.notice.notices_menu"), core.notices_path,
           %r{^notices})
end

Core::Notice.register_def_per_user_handler

Core::Notice.register_kind 'jobstat' do |notice, user, params, request|
  nil
end
