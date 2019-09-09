module Hardware
  module ApplicationHelper
    def hardware_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("hardware.engine_submenu.kinds"),
                                admin_kinds_path, 'hardware/admin/kinds')

      menu.add_item_without_key(t("hardware.engine_submenu.items"),
                                admin_items_path, 'hardware/admin/items')
      menu.add_item_without_key(t("hardware.engine_submenu.items_states"),
                                admin_items_states_path, 'hardware/admin/items_states')


      # items_menu_item = Face::MenuItem.new(name: t("hardware.engine_submenu.items"),
      #                                   url: [:admin, :items],
      #                                   regexp: /items/)
      # def items_menu_item.active?(current_url)
      #   /items/ =~ current_url && /items_state/ !~ current_url
      # end
      # menu.add_item(items_menu_item)
      # menu.add_item(Face::MenuItem.new(name: t("hardware.engine_submenu.items_states"),
      #                                   url: [:admin, :items_states],
      #                                   regexp: /items_states/))
      #

      menu.items(self)
    end
  end
end
