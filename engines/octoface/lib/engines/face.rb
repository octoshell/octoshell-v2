module Face
  extend Octoface
  octo_configure :face do
    add_routes do
      mount Face::Engine, :at => "/"
    end
    after_init do
      Face::MyMenu.items_for(:user_submenu) do
        add_item('menu_items', t('user_submenu.menu_items'), face.edit_all_menu_items_path, 'face/menu_items')
      end
    end
  end
end
