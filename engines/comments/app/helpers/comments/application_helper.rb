module Comments
  module ApplicationHelper
    def comments_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t('engine_submenu.group_classes_links'),
                                edit_admin_group_classes_path, 'comments/admin/group_classes')

      menu.add_item_without_key(t('engine_submenu.contexts'),
                                admin_contexts_path, 'comments/admin/contexts')

      menu.add_item_without_key(t('engine_submenu.context_groups_links'),
                                edit_admin_context_groups_path, 'comments/admin/context_groups')

      menu.items(self)
    end

    def comments_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(Comment.model_name.human,
                                index_all_comments_path, 'comments/comments')

      menu.add_item_without_key(FileAttachment.model_name.human,
                                index_all_files_path, 'comments/files')

      menu.add_item_without_key(Tag.model_name.human,
                                tags_lookup_index_path, 'comments/tags_lookup')
      menu.items(self)
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
