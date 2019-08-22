ApplicationController.class_eval do
  # def ability
  #   @ability ||= begin
  #                  current_user && current_user.extend(UserAbilities)
  #                  if logged_in?
  #                    current_user.ability
  #                  else
  #                    mm = MayMay::Ability.new(nil)
  #                    mm.maynot(:access, :admin)
  #                    mm.maynot(:view, :projects)
  #                    mm
  #                  end
  #                end
  # end

  helper_method :menu_items
  helper_method :user_submenu_items
  helper_method :admin_submenu_items

  def menu_items
    menu = Face::Menu.new
    menu.items.clear
    menu.add_item(working_area_item) if logged_in?
    menu.add_item(admin_area_item) if can?(:access, :admin)
    menu.add_item(wiki_item)
    menu.add_item(wikiplus_item)
    menu.items
  end

  def wiki_item
    Face::MenuItem.new({
      name: t("main_menu.wiki"),
      url: wiki.root_path,
      regexp: /wiki/
    })
  end

  def wikiplus_item
    Face::MenuItem.new({
      name: t("main_menu.wikiplus"),
      url: wikiplus.root_path,
      regexp: /wikiplus/
    })
  end

  def working_area_item
    Face::MenuItem.new({
      name: t("main_menu.working_area"),
      url: core.root_path,
      regexp: /^((?!admin|wiki).)*$/s
    })
  end

  def admin_area_item
    Face::MenuItem.new({
      name: t("main_menu.admin_area"),
      url: core.admin_projects_path,
      regexp: /admin/
    })
  end

  # TODO: workout mess
  def user_submenu_items
    menu = Face::Menu.new
    menu.items.clear
    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.profile"),
    #                                   url: main_app.profile_path,
    #                                   regexp: /(?:profile|(?:employments|organizations))/}))

    # tickets_warning = current_user.tickets.where(state: :answered_by_support).any?
    # tickets_title = if tickets_warning
    #                   t("user_submenu.tickets_warning.html").html_safe
    #                  else
    #                   t("user_submenu.tickets")
    #                  end
    # menu.add_item(Face::MenuItem.new({name: tickets_title,
    #                                   url: support.tickets_path,
    #                                   regexp: /support/}))

    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.projects"),
    #                                   url: core.projects_path,
    #                                   regexp: /core\/(?:projects|)(?!employments|organizations)/}))
    # sessions_warning = current_user.warning_surveys.exists? ||
    #                    current_user.warning_reports.exists?
    # sessions_title = if sessions_warning
    #                   t("user_submenu.sessions_warning.html").html_safe
    #                  else
    #                   t("user_submenu.sessions")
    #                  end
    # menu.add_item(Face::MenuItem.new({name: sessions_title,
    #                                   url: sessions.reports_path,
    #                                   regexp: /sessions/}))
    #
    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.packages"),
    #                                   url: pack.root_path,
    #                                   regexp: /pack/}))

    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.job_stat"),
    #                                   url: jobstat.account_summary_show_path,
    #                                   regexp: /account\/summary/}))
    #
    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.job_table"),
    #                                   url: jobstat.account_list_index_path,
    #                                   regexp: /account\/list/}))
    # menu.add_item(Face::MenuItem.new(name: t("user_submenu.comments"),
    #                                   url: comments.index_all_comments_path))

    # menu.items
    # Face::MyMenu.user_submenu(self) + menu.items.to_a
    Face::MyMenu.user_submenu(self)
  end

  def admin_submenu_items
    menu = Face::Menu.new
    menu.items.clear
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.users"),
    #                                   url: main_app.admin_users_path,
    #                                   regexp: /admin\/users/})) if  :manage, :users
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.projects"),
    #                                   url: core.admin_projects_path,
    #                                   regexp: /core\/admin\/projects/})) if  :manage, :projects

    # menu.add_item(Face::MenuItem.new({name: t("user_submenu.packages"),
    #                                   url: pack.admin_root_path,
    #                                   regexp: /pack\/admin/}))  if  :manage, :packages
    # tickets_count = Support::Ticket.where(state: [:pending, :answered_by_reporter]).count
    # support_title = if tickets_count.zero?
    #                    t("admin_submenu.support")
    #                  else
    #                    t("admin_submenu.support_with_count.html", count: tickets_count).html_safe
    #                  end
    # menu.add_item(Face::MenuItem.new({name: support_title,
    #                                   url: support.admin_root_path,
    #                                   regexp: /support/})) if  :manage, :tickets

    # sureties_count = Core::Surety.where(state: :confirmed).count
    # sureties_title = if sureties_count.zero?
    #                    t("admin_submenu.sureties")
    #                  else
    #                    t("admin_submenu.sureties_with_count.html", count: sureties_count).html_safe
    #                  end
    # menu.add_item(Face::MenuItem.new({name: sureties_title,
    #                                   url: core.admin_sureties_path,
    #                                   regexp: /core\/admin\/sureties/})) if  :manage, :sureties
    #
    # requests_count = Core::Request.where(state: :pending).count
    # requests_title = if requests_count.zero?
    #                    t("admin_submenu.requests")
    #                  else
    #                    t("admin_submenu.requests_with_count.html", count: requests_count).html_safe
    #                  end
    # menu.add_item(Face::MenuItem.new({name: requests_title,
    #                                   url: core.admin_requests_path,
    #                                   regexp: /core\/admin\/requests/})) if  :manage, :requests
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.reports"),
    #                                   url: sessions.admin_reports_path,
    #                                   regexp: /sessions\/admin\/reports/ })) if  :manage, :reports
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.sessions"),
    #                                   url: sessions.admin_sessions_path,
    #                                   regexp: /sessions\/admin\/(?:sessions|surveys)/})) if  :manage, :sessions

    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.organizations"),
    #                                   url: core.admin_organizations_path,
    #                                   regexp: /organizations/})) if  :manage, :organizations
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.clusters"),
    #                                   url: core.admin_clusters_path,
    #                                   regexp: %r{admin/clusters/} })) if  :manage, :clusters
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.cluster_logs"),
    #                                   url: core.admin_cluster_logs_path,
    #                                   regexp: /cluster_logs/})) if  :manage, :clusters
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.quota_kinds"),
    #                                   url: core.admin_quota_kinds_path,
    #                                   regexp: /quota_kinds/})) if  :manage, :clusters
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.project_kinds"),
    #                                   url: core.admin_project_kinds_path,
    #                                   regexp: /project_kinds/})) if  :manage, :projects
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.organization_kinds"),
    #                                   url: core.admin_organization_kinds_path,
    #                                   regexp: /organization_kinds/})) if  :manage, :organizations
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.groups"),
    #                                   url: main_app.admin_groups_path,
    #                                   regexp: %r{admin/groups/} })) if  :manage, :groups
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.report_submit_denial_reasons"),
    #                                   url: sessions.admin_report_submit_denial_reasons_path,
    #                                   regexp: /report_submit_denial_reasons/})) if  :manage, :sessions
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.direction_of_sciences"),
    #                                   url: core.admin_direction_of_sciences_path,
    #                                   regexp: /direction_of_sciences/})) if  :manage, :projects
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.critical_technologies"),
    #                                   url: core.admin_critical_technologies_path,
    #                                   regexp: /critical_technologies/})) if  :manage, :projects
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.research_areas"),
    #                                   url: core.admin_research_areas_path,
    #                                   regexp: /research_areas/})) if  :manage, :projects
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.statistics"),
    #                                   url: statistics.projects_path,
    #                                   regexp: /admin\/statistics/})) if User.superadmins.include? current_user
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.announcements"),
    #                                   url: announcements.admin_announcements_path,
    #                                   regexp: /admin\/announcements/})) if User.superadmins.include?(current_user)|| current_user.mailsender?
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.sidekiq"),
    #                                   url: main_app.admin_sidekiq_web_path})) if User.superadmins.include? current_user
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.countries"),
    #                                   url: core.admin_countries_path})) if User.superadmins.include? current_user
    # menu.add_item(Face::MenuItem.new({name: t("admin_submenu.cities"),
    #                                   url: core.admin_cities_path})) if User.superadmins.include? current_user
    # menu.add_item(Face::MenuItem.new(name: t("admin_submenu.comments"),
    #                                   url: comments.edit_admin_group_classes_path)) if User.superadmins.include? current_user


    # if  :manage, :hardware
    #   menu.add_item(Face::MenuItem.new(name: t("admin_submenu.hardware"),
    #                                     url: hardware.admin_root_path))
    # end

    # if User.superadmins.include? current_user
    #   menu.add_item(Face::MenuItem.new(name: t("admin_submenu.emails"),
    #                                    url: main_app.rails_email_preview_path,
    #                                    regexp: /admin\/emails/
    #                                 ))
    #
    #   menu.add_item(Face::MenuItem.new(name: t("admin_submenu.options"),
    #                                    url: main_app.admin_options_categories_path,
    #                                    regexp: /admin\/options/
    #                                 ))
    #   menu.add_item(Face::MenuItem.new(name: t("admin_submenu.journal"),
    #                                     url: "/core/admin/journal"))
    # end
    #

    # menu.add_item(Face::MenuItem.new(name: t("admin_submenu.reports_engine"),
    #                                  url: main_app.reports_path,
    #                               ))  if  can?(:manage, :reports_engine)
    menu.add_item(Face::MenuItem.new(name: t("admin_submenu.api"),
                                     url: api.admin_access_keys_path)
                 ) if can? :manage, :api_engine

    menu.add_item(Face::MenuItem.new(name: t("admin_submenu.wikiplus"),
                                     url: wikiplus.admin_pages_path,
                                     regexp: /admin\/wikiplus/
                 ))  if can? :manage, :wikiplus


    Face::MyMenu.admin_submenu(self) + menu.items.to_a

    # menu.items
  end
end
