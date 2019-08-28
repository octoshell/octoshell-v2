ApplicationController.class_eval do
  helper_method :menu_items
  helper_method :user_submenu_items
  helper_method :admin_submenu_items

  def menu_items
    menu = Face::Menu.new
    menu.items.clear
    menu.add_item(working_area_item) if logged_in?
    menu.add_item(admin_area_item) if can?(:access, :admin)
    menu.add_item(wiki_item)
    menu.add_item(wikiplus_item)
    menu.items
  end

  def wiki_item
    Face::MenuItem.new({
      name: t("main_menu.wiki"),
      url: wiki.root_path,
      regexp: /wiki/
    })
  end

  def wikiplus_item
    Face::MenuItem.new({
      name: t("main_menu.wikiplus"),
      url: wikiplus.root_path,
      regexp: /wikiplus/
    })
  end

  def working_area_item
    Face::MenuItem.new({
      name: t("main_menu.working_area"),
      url: core.root_path,
      regexp: /^((?!admin|wiki).)*$/s
    })
  end

  def admin_area_item
    Face::MenuItem.new({
      name: t("main_menu.admin_area"),
      url: core.admin_projects_path,
      regexp: /admin/
    })
  end

  # TODO: workout mess
  def user_submenu_items
    Face::MyMenu.user_submenu(self)
  end

  def admin_submenu_items
    Face::MyMenu.admin_submenu(self)
  end
end
