module Octoface
  extend Octoface
  octo_configure :octoface do
    add_ability(:show, :octoface, 'superadmins')
    add_routes do
      mount Octoface::Engine, :at => "/octoface"
    end
    after_init do
      Face::MyMenu.items_for(:admin_submenu) do
        if can? :show, :octoface
          add_item('octoface_engine', t("admin_submenu.octoface"), octoface.admin_roles_path,'octoface/admin/roles')
        end
      end
    end
  end
end
