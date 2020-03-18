Face::MyMenu.items_for(:admin_submenu) do
  add_item_if_may('announcements', t('admin_submenu.announcements'),
                  announcements.admin_announcements_path,
                  'announcements/admin/announcements')
end
