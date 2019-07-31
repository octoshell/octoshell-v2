module Announcements
  extend Octoface
  octo_configure do
    # add :report_class, Report # теперь во всех модулях доступен report_class
    add_ability(:manage, :announcements, 'superadmins', 'mailsenders')
    add_controller_ability(:manage, :announcements, 'admin/announcements')
    add_routes do
      mount Engine, at: '/announcements'
    end
  end
end

Face::MyMenu.items_for(:admin_submenu) do
  add_item_if_may(t('admin_submenu.announcements'),
                  announcements.admin_announcements_path,
                  'announcements/admin/announcements')
end


# # Octoshell::Application.routes.draw do
# #   mount Announcements::Engine, :at => "/announcements"
# end
