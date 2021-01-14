module CloudComputing
  module ApplicationHelper


    def cloud_computing_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("cloud_computing.engine_submenu.item_list"),
                                items_path, 'cloud_computing/items')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.item_kind_list"),
                                item_kinds_path, 'cloud_computing/item_kinds')

      if can?(:create, CloudComputing::Request)
        menu.add_item_without_key(t("cloud_computing.engine_submenu.request_list"),
                                  requests_path, 'cloud_computing/admin/request')
      end
      menu.add_item_without_key(t("cloud_computing.engine_submenu.access_list"),
                                accesses_path, 'cloud_computing/accesses')

      menu.items(self)
    end

    def cloud_computing_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("cloud_computing.engine_submenu.resource_kind_list"),
                                admin_resource_kinds_path, 'cloud_computing/admin/resource_kinds')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.item_list"),
                                admin_items_path, 'cloud_computing/admin/items')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.item_kind_list"),
                                admin_item_kinds_path, 'cloud_computing/admin/item_kinds')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.request_list"),
                                admin_requests_path, 'cloud_computing/admin/requests')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.access_list"),
                                admin_accesses_path, 'cloud_computing/admin/accesses')
      menu.items(self)
    end

    def mark_request_state(request)
      labels = { 'created' => 'primary', 'sent' => 'info',
                 'approved' => 'success',
                 'refused' => 'danger', 'cancelled' => 'warning' }
      label_class = labels[request.status]
      content_tag(:span, class: "label label-#{label_class} lg") do
        request.human_state_name
      end
    end

    def mark_access_state(access)
      labels = { 'created' => 'primary', 'approved' => 'success',
                 'finished' => 'secondary', 'denied' => 'danger' }
      label_class = labels[access.state]
      content_tag(:span, class: "label label-#{label_class} lg") do
        access.human_state_name
      end
    end

    def resource_kind_show_attrs(r_k)
      {
        name: nil,
        item_kind_id: link_to(r_k.item_kind.name, [:admin, r_k.item_kind]),
        content_type: r_k.human_content_type,
        %i[measurement help description] => nil
      }
    end


    def vm_human_state(n_i)

      if n_i.state == 'ACTIVE' && n_i.lcm_state == 'RUNNING'
        human_state = t('cloud_computing.vm_human_state.running')
        return "(#{human_state})"
      end
      ''
    end

    def admin_item_show_attrs(item)
      {
        name: nil,
        item_kind_id: link_to(item.item_kind.name, [:admin, item.item_kind]),
        description: nil,
        new_requests: t(item.new_requests),
        identity: nil
      }
    end
  end
end
