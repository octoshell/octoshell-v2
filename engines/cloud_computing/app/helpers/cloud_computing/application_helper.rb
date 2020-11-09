module CloudComputing
  module ApplicationHelper
    def cloud_computing_submenu_items
      []
    end

    def cloud_computing_admin_submenu_items
      menu = Face::MyMenu.new
      menu.add_item_without_key(t("engine_submenu.cluster_list"),
                                admin_clusters_path, 'cloud_computing/admin/clusters')
      menu.add_item_without_key(t("engine_submenu.resource_kind_list"),
                                admin_resource_kinds_path, 'cloud_computing/admin/resource_kinds')
      menu.add_item_without_key(t("engine_submenu.configuration_list"),
                                admin_configurations_path, 'cloud_computing/admin/configurations')

      menu.items(self)
    end

  end
end
