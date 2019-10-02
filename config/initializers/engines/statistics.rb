module Statistics
  extend Octoface
  octo_configure :statistics do

  end
end


Face::MyMenu.items_for(:admin_submenu) do
  if User.superadmins.include? current_user
    add_item('statistics', t("admin_submenu.statistics"), statistics.projects_path, %r{statistics/admin})
  end
end
