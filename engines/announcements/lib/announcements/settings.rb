module Announcements
  extend Octoface
  octo_configure :announcements do
    add_ability(:manage, :announcements, 'superadmins', 'mailsenders')
    add_controller_ability(:manage, :announcements, 'admin/announcements')
    add_routes do
      mount Engine, at: '/announcements'
    end
    after_init do
      Announcements.user_class = '::User'
      Face::MyMenu.items_for(:admin_submenu) do
        add_item_if_may('announcements', t('admin_submenu.announcements'),
                        announcements.admin_announcements_path,
                        'announcements/admin/announcements')
      end
    end
  end
end
