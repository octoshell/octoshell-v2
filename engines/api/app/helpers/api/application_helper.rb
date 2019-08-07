module Api
  module ApplicationHelper
    def api_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear

      access_keys_menu = Face::MenuItem.new(name: t("api.engine_submenu.access_keys"),
                                        url: :access_keys,
                                        regexp: /access_keys/)
      def access_keys_menu.active?(current_url)
        /access_keys/ =~ current_url
      end
      menu.add_item(access_keys_menu)

      exports_menu = Face::MenuItem.new(name: t("api.engine_submenu.exports"),
                                        url: :exports,
                                        regexp: /exports/)
      def exports_menu.active?(current_url)
        /exports/ =~ current_url
      end
      menu.add_item(exports_menu)

      key_parameters_menu = Face::MenuItem.new(name: t("api.engine_submenu.key_parameters"),
                                        url: :key_parameters,
                                        regexp: /key_parameters/)
      def key_parameters_menu.active?(current_url)
        /key_parameters/ =~ current_url
      end
      menu.add_item(key_parameters_menu)

      menu.items
    end


    def api_submenu_items
    end
  end
end
