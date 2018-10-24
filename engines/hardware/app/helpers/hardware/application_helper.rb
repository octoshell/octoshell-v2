module Hardware
  module ApplicationHelper
    def hardware_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: t("hardware.engine_submenu.kinds"),
                                        url: [:admin, :kinds],
                                        regexp: /kinds/))
      menu.add_item(Face::MenuItem.new(name: t("hardware.engine_submenu.items"),
                                        url: [:admin, :items],
                                        regexp: /items/))


      menu.items
    end
  end
end
