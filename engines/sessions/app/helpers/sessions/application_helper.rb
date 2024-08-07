module Sessions
  module ApplicationHelper
    def sessions_user_submenu_items
      menu = Face::MyMenu.new
      # menu.items.clear
      bell_html = '<span class="badge warning"><i class="fa fa-bell"> </i></span>'
      surveys_any = current_user.warning_surveys.exists?
      reports_any = current_user.warning_reports.exists?
      html = reports_any ? "#{t("engine_submenu.reports")} #{bell_html}".html_safe : t("engine_submenu.reports")

      menu.add_item_without_key(html, sessions.reports_path, 'sessions/reports')

      # menu.add_item(Face::MenuItem.new({name: html,
      #                                   url: sessions.reports_path,
      #                                   regexp: /reports/}))


      html = surveys_any ? "#{t("engine_submenu.surveys")} #{bell_html}".html_safe : t("engine_submenu.surveys")


      menu.add_item_without_key(html, sessions.user_surveys_path, 'sessions/user_surveys')

      # menu.add_item(Face::MenuItem.new({name: html,
      #                                   url: sessions.user_surveys_path,
      #                                   regexp: /surveys/}))
      menu.items(self)
    end

    def report_points(access, method)
      result = access.send method
      return t('sessions.evaluate_helper.not_evaluated') unless result
      return t('sessions.evaluate_helper.without_mark') if result.zero?
      result
    end

    def possible_report_points
      [
        ['not_evaluated', t('sessions.evaluate_helper.not_evaluated')],
        [0, t('sessions.evaluate_helper.without_mark')],
        *(1..5).map { |n| [n, n.to_s] }
      ]
    end

    def form_report_points
      [[0, t('sessions.evaluate_helper.without_mark')]] +
        (1..5).map { |n| [n, n.to_s] }
    end

    def session_state_label(session)
      case session.state_name
      when :pending then
        "warning"
      when :active then
        "success"
      else
        "danger"
      end
    end

    def report_status_label(report)
      case report.state_name
      when :can_not_be_submitted then
        :primary
      when :accepted, :assessing, :filling, :postfilling then
        :warning
      when :submitted, :assessed then
        :success
      else
        :danger
      end
    end

    #colouring cells for expert's table
    def cell_colour(cnt, cnt_all)
      case
      when cnt <= cnt_all / 14 then "#FFFF99"
      when cnt <= cnt_all / 10 then "#98FB98"
      when cnt <= cnt_all / 8 then "#00FA9A"
      when cnt <= cnt_all / 4 then "#3CB371"
      else "#2E8B57"
      end
    end
  end
end
