module Core
  extend Octoface
  octo_configure do
    add_ability(:manage,  :notices, 'superadmins')
    add_ability(:destroy, :notices, 'superadmins') # <--- does not work
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :tickets)
    add_item('notices', t("notices"), core.admin_notices_path,
             %r{^notices})
  end
end

Core::Notice.register_def_per_user_handler

Core::Notice.register_kind 'jobstat' do |notice, user, params, request|
  nil
end
