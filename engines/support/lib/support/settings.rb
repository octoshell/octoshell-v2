module Support
  extend Octoface
  octo_configure :support do
    add_ability(:manage, :tickets, 'superadmins', 'support')
    add('Notificator')
    # add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
    add_routes do
      mount Support::Engine, :at => "/support"
    end
    add_ability do |user|
      if can?(:manage, :tickets)
        can :access, Support::Topic
      end
      user.available_topics.each do |user_topic|
        user_topic.all_subtopics_with_self.each do |u_t|
          can :access, Support::Topic, id: u_t.id
        end
      end
      can :access, :admin if user.available_topics.any?
    end
    after_init do
      Support.dash_number = 150
      Support.user_class = '::User'
      Face::MyMenu.items_for(:user_submenu) do
        tickets_warning = current_user.tickets.where(state: :answered_by_support).any?
        tickets_title = if tickets_warning
                          t("user_submenu.tickets_warning.html").html_safe
                         else
                          t("user_submenu.tickets")
                         end
        add_item('tickets', tickets_title, support.tickets_path, /^support/)

      end

      Face::MyMenu.items_for(:admin_submenu) do

        if can?(:manage, :tickets)
          tickets_count = Support::Ticket.where(state: [:pending, :answered_by_reporter]).count
          support_title = if tickets_count.zero?
                            t("admin_submenu.support")
                          else
                            t("admin_submenu.support_with_count.html", count: tickets_count).html_safe
                          end

          add_item('tickets', support_title, support.admin_root_path, %r{support/admin/})
        end
      end
    end

  end
end
