module Api
  extend Octoface
  octo_configure do
    add_ability(:manage, :api_engine, 'superadmins')
  end
end


Face::MyMenu.items_for(:admin_submenu) do
  if can? :manage, :api_engine
    add_item('api_engine', t("admin_submenu.api"), api.admin_access_keys_path,'sessions/admin/reports')
  end
end
