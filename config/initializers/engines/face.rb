Face::MyMenu.items_for(:user_submenu) do
  add_item('menu_items', t('user_submenu.menu_items'), face.edit_all_menu_items_path, 'face/menu_items')
end
