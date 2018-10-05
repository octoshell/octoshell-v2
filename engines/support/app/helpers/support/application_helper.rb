module Support
  module ApplicationHelper

    def responsible_user_topics(ticket)
      ticket.possible_responsibles.map do |r|
        user_topics_array = r.second
        user_topics_res = []
        formed_string = [r.first.full_name]
        if r.second.any?
          user_topics_array.each do |user_topic|
            string = user_topic.topic.name
            string << "(#{UserTopic.human_attribute_name(:required)})" if user_topic.required
            user_topics_res << string
          end
        end
        [r.first.id, formed_string.join(' '), user_topics_res]
      end
    end

    def support_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.tickets_list"),
                                        url: [:admin, :tickets],
                                        regexp: /tickets/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.reply_templates"),
                                        url: [:admin, :reply_templates],
                                        regexp: /reply_templates/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.tags"),
                                        url: [:admin, :tags],
                                        regexp: /tags/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.topics"),
                                        url: [:admin, :topics],
                                        regexp: /topics/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.fields"),
                                        url: [:admin, :fields],
                                        regexp: /fields/}))
      menu.items
    end

    def link_to_attachment(record)
      if record.attachment?
        "#{link_to File.basename(record.attachment.url), record.attachment.url, target: :blank} #{number_to_human_size(record.attachment.size)}".html_safe
      end
    end
  end
end
