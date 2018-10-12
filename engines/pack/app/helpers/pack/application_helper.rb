module Pack
  module ApplicationHelper

    def add_version(t, version)
      if version
        t
      else
        "version_#{t}"
      end
    end

    def show_errors(f, attr)
      if f.object.errors[attr]!=[]
        errors=f.object.errors[attr].join(" ")
        content_tag("p", content_tag("font",errors,color: "red")  )
      end
    end

    def readable_attrs(record)
      record.attributes.reject{|key,value|  key.match(/_id$/) || ['id','lock_version','updated_at','created_at'].include?(key)  }
    end

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
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.versions_list"),
                                        url: [:admin, :versions],
                                        regexp: /versions/))
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.packages_list"),
                                        url: [:admin, :packages],
                                        regexp: /packages/))

      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.accesses_list"),
                                        url: [:admin, :accesses],
                                        regexp: /accesses/))
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.options_list"),
                                        url: [:admin, :options_categories],
                                        regexp: /options_categories/))
      menu.add_item(Face::MenuItem.new(name: t("pack.docs.docs_ru.header"),
                                        url: { controller: "/pack/docs", action: "show", page: 'docs_ru' },
                                        regexp: /docs/))
      menu.items
    end

    def pack_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.versions_list"),
                                        url: [:versions],
                                        regexp: /versions/))
      menu.add_item(Face::MenuItem.new(name: t("engine_submenu.packages_list"),
                                        url: [:packages],
                                        regexp: /packages/))
      menu.add_item(Face::MenuItem.new(name: t("pack.docs.docs_ru.header"),
                                        url: { controller: "docs", action: "show", page: 'docs_ru' },
                                        regexp: /docs/))

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
