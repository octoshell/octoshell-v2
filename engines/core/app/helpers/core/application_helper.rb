module Core
  module ApplicationHelper

    def no_name_c c
      c.title_ru.blank? ? t('core_no_name') : c.title_ru
    end

    def resource_control_color(r)
      case r.status
      when 'active'
        'green'
      when 'blocked'
        'red'
      when 'disabled'
        'purple'
      else
        'black'
      end
    end

    def queue_access_color(q)
      if q.synced_with_cluster
        return 'green' if q.active
        return 'red' if q.blocked

      else
        'blue'
      end
    end

    def provide_cities_hash_view
      @countries_meth = Country.all.order(:title_ru).includes(:cities).to_a
      @countries = @countries_meth
      @cities = {}
      @countries = @countries.map do |c|
        @cities[c.id] = c.cities.to_a.map(&:to_json_with_titles)
        c.to_json_with_titles
      end
    end

    def project_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.projects_list"),
                                admin_organizations_path, 'core/admin/projects')

      menu.add_item_without_key(t("engine_submenu.acess_management"),
                                admin_accesses_path, 'core/admin/accesses')

      menu.items(self)
    end

    def organizations_admin_submenu_items

      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.organizations_list"),
                                admin_organizations_path, 'core/admin/organizations')

      menu.add_item_without_key(t("engine_submenu.prepare_merge"),
                                admin_prepare_merge_index_path, 'core/admin/prepare_merge')
      menu.items(self)
    end
    def mark_project_state(project)
      label_class = case project.state
                    when "active"
                      "success"
                    when "pending"
                      "info"
                    when "suspended"
                      "warning"
                    else
                      "danger"
                    end

      "<span class=\"label label-#{label_class} lg\">#{project.human_state_name}</span>".html_safe
    end

    def mark_ownership(project)
      "<i class=\"fa fa-flag\"></i>".html_safe if current_user == project.owner
    end

    def mark_member_state(project, member)
      label_class = case member.project_access_state
                    when "invited"
                      "info"
                    when "engaged"
                      "primary"
                    when "unsured"
                      "warning"
                    when "denied"
                      "danger"
                    when "suspended"
                      "danger"
                    else
                      "success"
                    end

      "<span class=\"label label-#{label_class} lg\">#{member.human_project_access_state_name}</span>".html_safe
    end

    def mark_request_state(request)
      label_class = case request.state
                    when "active"
                      "success"
                    when "pending"
                      "warning"
                    else
                      "danger"
                    end

      "<span class=\"label label-#{label_class} lg\">#{request.human_state_name}</span>".html_safe
    end

    def link_to_support
      custom_helper(:support, :new_ticket_link)
    end


  end
end
