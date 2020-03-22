module Hardware
  extend Octoface
  octo_configure :hardware do
    add_ability(:manage, :hardware, 'superadmins')
    add_routes do
      mount Hardware::Engine, :at => "/hardware"
    end
    after_init do
      Face::MyMenu.items_for(:admin_submenu) do
        if can?(:manage, :hardware)
          add_item('hardware', t("admin_submenu.hardware"), hardware.admin_root_path, %r{hardware/admin})
        end
      end
    end
  end
end
