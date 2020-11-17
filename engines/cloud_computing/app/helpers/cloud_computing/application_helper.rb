module CloudComputing
  module ApplicationHelper
    def cloud_computing_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.item_list"),
                                items_path, 'cloud_computing/items')
      menu.add_item_without_key(t("engine_submenu.item_kind_list"),
                                item_kinds_path, 'cloud_computing/item_kinds')

      menu.items(self)
    end

    def cloud_computing_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.cluster_list"),
                                admin_clusters_path, 'cloud_computing/admin/clusters')
      menu.add_item_without_key(t("engine_submenu.resource_kind_list"),
                                admin_resource_kinds_path, 'cloud_computing/admin/resource_kinds')
      menu.add_item_without_key(t("engine_submenu.item_list"),
                                admin_items_path, 'cloud_computing/admin/items')
      menu.add_item_without_key(t("engine_submenu.item_kind_list"),
                                admin_item_kinds_path, 'cloud_computing/admin/item_kinds')

      menu.items(self)
    end

  end
end
