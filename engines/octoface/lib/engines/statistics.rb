module Statistics
  extend Octoface
  octo_configure :statistics do
    add_routes do
      mount Statistics::Engine, :at => "/admin/stats"
    end
    after_init do
      Face::MyMenu.items_for(:admin_submenu) do
        if User.superadmins.include? current_user
          add_item('statistics', t("admin_submenu.statistics"), statistics.projects_path, %r{statistics/admin})
        end
      end
    end
  end
end
