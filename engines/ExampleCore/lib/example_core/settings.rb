module ExampleCore
  extend Octoface
  octo_configure :core do
    add_ability(:manage, :projects, 'superadmins')

    add_ability do |user|
      if can?(:access, :admin)
        can :read, ExampleCore::Topic, id: 1
      end
    end
    add_controller_ability(:manage, :projects, 'admin/projects',
                           'admin/project_kinds')
    add_routes do
      mount ExampleCore::Engine, :at => "/example_core"
    end

    after_init do
      Face::MyMenu.items_for(:admin_submenu) do
        if can? :manage, :projects
          add_item('projects', t('admin_submenu.projects'),
                    example_core.admin_projects_path, %r{^example_core/admin/projects})

          add_item('research_projects', t('admin_submenu.research_projects'), example_core.admin_research_projects_path,
          'example_core/admin/research_projects')
        end
        add_item_if_may('project_kinds', t("admin_submenu.project_kinds"), example_core.admin_project_kinds_path, 'example_core/admin/project_kinds')

      end

      Face::MyMenu.items_for(:user_submenu) do
        tickets_warning = current_user.tickets.where(state: :answered_by_support).any?
        tickets_title = if tickets_warning
                          t("user_submenu.tickets_warning.html").html_safe
                        else
                          t("user_submenu.tickets")
                        end
        add_item('tickets', tickets_title, example_core.tickets_path, /^example_core/)
      end
    end
  end
end