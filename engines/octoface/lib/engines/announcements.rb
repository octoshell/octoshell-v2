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
