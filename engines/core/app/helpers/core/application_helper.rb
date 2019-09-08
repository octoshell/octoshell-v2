module Core
  module ApplicationHelper

    def no_name_c c
      c.title_ru.blank? ? t('core_no_name') : c.title_ru
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

    def organizations_admin_submenu_items

      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.organizations_list"),
                                admin_organizations_path, 'core/admin/organizations')

      # menu.add_item_without_key(t("engine_submenu.merge_edit"),
      #                           merge_edit_admin_organizations_path)

      menu.add_item_without_key(t("engine_submenu.prepare_merge"),
                                admin_prepare_merge_index_path, 'core/admin/prepare_merge')

      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.organizations_list"),
      #                                   url: [:admin, :organizations],
      #                                   regexp: /organizations/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.merge_edit"),
      #                                   url: [:merge_edit, :admin, :organizations],
      #                                   regexp: /merge_edit/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.prepare_merge"),
      #                                   url: [:admin, :prepare_merge,:index],
      #                                   regexp: /merge_edit/}))

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
  end
end
