Support.dash_number = 150

module Support
  extend Octoface
  octo_configure do
    add_ability(:manage, :tickets, 'superadmins', 'support')
    # add_controller_ability(:manage, :reports, 'admin/reports', 'admin/report_projects')
  end
end

Face::MyMenu.items_for(:user_submenu) do
  tickets_warning = current_user.tickets.where(state: :answered_by_support).any?
  tickets_title = if tickets_warning
                    t('user_submenu.tickets_warning.html').html_safe
                  else
                    t('user_submenu.tickets')
                  end
  add_item('tickets', tickets_title, support.tickets_path, /^support/)
end

Face::MyMenu.items_for(:admin_submenu) do
  if can?(:manage, :tickets)
    tickets_count = Support::Ticket.where(
      state: %i[pending answered_by_reporter]
    ).count
    support_title = if tickets_count.zero?
                      t('admin_submenu.support')
                    else
                      t(
                        'admin_submenu.support_with_count.html',
                        count: tickets_count
                      ).html_safe
                    end

    add_item('tickets', support_title,
             support.admin_root_path, %r{support/admin/})
  end
end
