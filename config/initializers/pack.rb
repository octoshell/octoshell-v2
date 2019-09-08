Pack.expire_after = 6.months
module Pack
  def self.support_access_topic
    Support::Topic.find_or_create_by!(name_ru: 'Заявка на доступ к пакету',
                                      name_en: 'Request for package',
                                      parent_topic: Support::Notificator.parent_topic)
  end
  extend Octoface
  octo_configure do
    add_ability(:manage, :packages, 'superadmins')
  end
end


Face::MyMenu.items_for(:user_submenu) do
  add_item('packages', t("user_submenu.packages"), pack.root_path, /^pack/)
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :packages)
    add_item('packages', t('user_submenu.packages'), pack.admin_root_path, %r{pack/admin/})
  end
end
