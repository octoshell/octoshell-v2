module Support
  module ApplicationHelper

    def responsible_user_topics(ticket)
      ticket.possible_responsibles.map do |user, user_topics_array|
        # user_topics_array = r.second
        user_topics_res = []
        formed_string = [user.full_name]
        if user_topics_array.any?
          user_topics_array.each do |user_topic|
            string = user_topic.topic.name.clone
            string << "(#{UserTopic.human_attribute_name(:required)})" if user_topic.required
            user_topics_res << string
          end
        end
        [user.id, formed_string.join(' '), user_topics_res]
      end
    end

    def support_admin_submenu_items
      menu = Face::MyMenu.new
      if can?(:access, Support::Topic)
        menu.add_item_without_key(t("engine_submenu.tickets_list"),
                                  admin_tickets_path, 'support/admin/tickets')
      end
      if can?(:manage, :tickets)
        menu.add_item_without_key(t("engine_submenu.reply_templates"),
                                  admin_reply_templates_path, 'support/admin/reply_templates')

        menu.add_item_without_key(t("engine_submenu.tags"),
                                  admin_tags_path, 'support/admin/tags')

        menu.add_item_without_key(t("engine_submenu.topics"),
                                  admin_topics_path, 'support/admin/topics')

        menu.add_item_without_key(t("engine_submenu.fields"),
                                  admin_fields_path, 'support/admin/fields')
      end


      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.tickets_list"),
      #                                   url: [:admin, :tickets],
      #                                   regexp: /tickets/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.reply_templates"),
      #                                   url: [:admin, :reply_templates],
      #                                   regexp: /reply_templates/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.tags"),
      #                                   url: [:admin, :tags],
      #                                   regexp: /tags/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.topics"),
      #                                   url: [:admin, :topics],
      #                                   regexp: /topics/}))
      # menu.add_item(Face::MenuItem.new({name: t("engine_submenu.fields"),
      #                                   url: [:admin, :fields],
      #                                   regexp: /fields/}))
      menu.items(self)
    end

    def link_to_attachment(record)
      if record.attachment?
        "#{link_to File.basename(record.attachment.url), record.attachment.url, target: :blank} #{number_to_human_size(record.attachment.size)}".html_safe
      end
    end

    def show_field_value(field_value, admin = false)

      return if field_value.value.blank?

      field = field_value.field
      if field.model_collection.present?
        model_field = ModelField.all[field.model_collection.to_sym]
        instance = model_field.model.find(field_value.value)
        return unless instance

        human = instance.public_send(model_field.human)
        link_type = admin ? :admin_link : :user_link
        if model_field.send(link_type) ## && model_field.link[:if].call(controller)
          path = controller.instance_exec(field_value.value, &model_field.send(link_type))
          return human unless path

          link_to(human, path)
        else
          instance.send(model_field.human)
        end
      elsif field.field_options.any?
        field.field_options.find(field_value.value).name
      else
        value
      end
    end
  end
end
