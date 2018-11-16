module Hardware
  module ApplicationHelper
    def hardware_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new(name: t("hardware.engine_submenu.kinds"),
                                        url: [:admin, :kinds],
                                        regexp: /kinds/))

      items_menu_item = Face::MenuItem.new(name: t("hardware.engine_submenu.items"),
                                        url: [:admin, :items],
                                        regexp: /items/)
      def items_menu_item.active?(current_url)
        /items/ =~ current_url && /items_state/ !~ current_url
      end
      menu.add_item(items_menu_item)
      menu.add_item(Face::MenuItem.new(name: t("hardware.engine_submenu.items_states"),
                                        url: [:admin, :items_states],
                                        regexp: /items_states/))


      menu.items
    end
  end
end
