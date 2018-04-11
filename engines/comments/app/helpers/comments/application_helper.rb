module Comments
  module ApplicationHelper
    def comments_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.group_classes_links"),
                                       url: [:edit,:admin, :group_classes],
                                       regexp: /group_classes/))
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.contexts"),
                                      url: [:admin, :contexts],
                                      regexp: /contexts/))
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.context_groups_links"),
                                      url: [:edit,:admin, :context_groups],
                                      regexp: /context_groups/))
      # menu.add_item(Face::MenuItem.new(name: t("engine_submenu.user_guide"),
      #                                 url: [:edit,:admin, :context_groups],
      #                                 regexp: /context_groups/))

      menu.items
    end

    def comments_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: Comment.model_name.human.to_s,
                                       url: index_all_comments_path,
                                       ))
      menu.add_item(Face::MenuItem.new(name: FileAttachment.model_name.human.to_s,
                                       url: index_all_files_path,
                                       ))
      menu.add_item(Face::MenuItem.new(name: Tag.model_name.human,
                                      url: tags_lookup_index_path,
                                      regexp: /tags_lookup/
                                      ))

      menu.items
    end

    def handlebars_tag(html_options = {}, &block)
      html_options = html_options.dup
      html_options[:type] = 'text/x-handlebars-template'
      content_tag(:script, html_options) do
        yield block
      end
    end
  end
end
