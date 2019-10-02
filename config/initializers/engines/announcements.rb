module Announcements
  extend Octoface
  octo_configure :announcements do
    add_ability(:manage, :announcements, 'superadmins', 'mailsenders')
    add_controller_ability(:manage, :announcements, 'admin/announcements')
    add_routes do
      mount Engine, at: '/announcements'
    end
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  add_item_if_may('announcements', t('admin_submenu.announcements'),
                  announcements.admin_announcements_path,
                  'announcements/admin/announcements')
end
