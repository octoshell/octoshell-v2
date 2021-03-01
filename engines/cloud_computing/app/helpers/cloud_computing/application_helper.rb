module CloudComputing
  module ApplicationHelper


    def cloud_computing_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("cloud_computing.engine_submenu.item_list"),
                                templates_path, 'cloud_computing/templates')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.template_kind_list"),
                                template_kinds_path, 'cloud_computing/template_kinds')

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
      menu.add_item_without_key(t("cloud_computing.engine_submenu.template_list"),
                                admin_templates_path, 'cloud_computing/admin/templates')
      menu.add_item_without_key(t("cloud_computing.engine_submenu.template_kind_list"),
                                admin_template_kinds_path, 'cloud_computing/admin/template_kinds')
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
                 'finished' => 'danger', 'denied' => 'danger',
                 'prepared_to_deny' => 'warning',
                 'prepared_to_finish' => 'warning' }
      label_class = labels[access.state] || 'primary'
      content_tag(:span, class: "label label-#{label_class} lg") do
        access.human_state_name
      end
    end

    def resource_kind_show_attrs(r_k)
      {
        name: nil,
        template_kind_id: link_to(r_k.template_kind.name, [:admin, r_k.template_kind]),
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

    def admin_template_show_attrs(template)
      {
        name: nil,
        template_kind_id: link_to(template.template_kind.name, [:admin, template.template_kind]),
        description: nil,
        new_requests: t(template.new_requests),
        identity: nil
      }
    end

    def json_templates
      CloudComputing::Template.virtual_machine_templates.map { |template|
        editable_resources = template.editable_resources.order(:resource_kind_id).map do |r|
          {
            resource_id: r.id,
            name: r.resource_kind.name,
            resource_kind_id: r.resource_kind_id,
            help: r.resource_kind.help,
            value: r.value,
            min: r.processed_min,
            max: r.processed_max,
            content_type: r.resource_kind.content_type
          }
        end
        hash = Hash[%i[id name description].map { |a| [a, template.send(a)] }]

        hash.merge(
          template_kind_name: template.template_kind.name,
          editable_resources: editable_resources
        )
      }.to_json.html_safe
    end

    def json_items(request, only_new_records = false)
      request.new_left_items
             .select { |i| only_new_records ? i.new_record? : true }
             .map do |item|
        resource_items = item.resource_items.to_a
                             .sort_by { |r| r.resource.resource_kind_id }
                             .map do |resource_item|
          hash = resource_item.attributes
          if resource_item.errors[:value].any?
            hash.merge(error: resource_item.errors.messages[:value].join(' '))
          else
            hash
          end
        end
        hash = Hash[%i[id template_id].map { |a| [a, item.send(a)] }]

        hash.merge(
          resource_items: resource_items
        )
      end.to_json.html_safe

    end

    def resource_item_and_old(resource_item)
      access_resource_item = resource_item.access_resource_item

      value = if access_resource_item && access_resource_item.value != resource_item.value
        content_tag(:font, resource_item.human_value_and_measurement, color: 'green') +
        ' ' +
        content_tag(:font, access_resource_item.human_value_and_measurement, color: 'red')
      else
        resource_item.human_value_and_measurement
      end

      "<b>#{resource_item.resource_kind.name}:</b> #{value}".html_safe
    end

  end
end
