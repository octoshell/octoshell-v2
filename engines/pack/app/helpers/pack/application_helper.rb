module Pack
  module ApplicationHelper

    def access_who_name(access)
      case access.who_type
      when 'Core::Project'
        link_to(access.who_name_with_type(access.who.title), core.admin_project_path(access.who_id))
      when 'User'
        link_to(access.who_name_with_type(access.who.full_name_with_email), main_app.admin_user_path(access.who_id))
      when 'Group'
        access.who_name_with_type
      end
    end

    def pack_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.packages_list"),
                                admin_packages_path, 'pack/admin/packages')
      menu.add_item_without_key(t("engine_submenu.versions_list"),
                                admin_versions_path, 'pack/admin/versions')
      menu.add_item_without_key(t("engine_submenu.accesses_list"),
                                admin_accesses_path, 'pack/admin/accesses')
      menu.add_item_without_key(t("pack.docs.docs_ru.header"),
                                { controller: "/pack/docs", action: "show",
                                  page: 'docs_ru' }, 'pack/docs')
      menu.items(self)
    end

    def pack_submenu_items
      menu = Face::MyMenu.new
      # menu.items.clear
      menu.add_item_without_key(t("engine_submenu.packages_list"),
                                packages_path, 'pack/packages')
      menu.add_item_without_key(t("engine_submenu.versions_list"),
                                versions_path, 'pack/versions')
      menu.add_item_without_key(t("pack.docs.docs_ru.header"),
                                { controller: "/pack/docs", action: "show",
                                  page: 'docs_ru' }, 'pack/docs')
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
