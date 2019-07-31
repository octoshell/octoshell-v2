Pack.expire_after = 6.months
module Pack
  extend Octoface
  octo_configure do
    add_ability(:manage, :packages, 'superadmins')
  end
end


Face::MyMenu.items_for(:user_submenu) do
  add_item(t("user_submenu.packages"), pack.root_path, /^pack/)
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :packages)
    add_item(t('user_submenu.packages'), pack.admin_root_path, %r{pack/admin/})
  end
end
