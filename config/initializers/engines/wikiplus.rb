Face::MyMenu.items_for(:admin_submenu) do
  if can? :manage, :wikiplus
    add_item('wiki', t("admin_submenu.wikiplus"),
             wikiplus.admin_pages_path, %r{admin/wikiplus})
  end
end
