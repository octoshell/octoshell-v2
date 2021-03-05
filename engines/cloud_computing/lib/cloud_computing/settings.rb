module CloudComputing
  extend Octoface
  octo_configure :cloud_computing do
    add_ability(:manage, :cloud, 'superadmins')
    add_ability(:test, :cloud, 'superadmins')

    add_ability do |user|
      if can?(:test, :cloud)
        can :read, CloudComputing::Access, for: user.projects
        can :update, CloudComputing::Access, for: user.owned_projects

        if user.owned_projects.active.any?
          can :create, CloudComputing::Request
        end
      end
    end

    add_routes do
      mount CloudComputing::Engine, :at => "/cloud_computing"
    end
    after_init do
      Face::MyMenu.items_for(:user_submenu) do
        add_item('cloud_computing', t('cloud_computing.user_submenu.cloud_computing'),
                 cloud_computing.root_path, /^cloud_computing/)
      end

      Face::MyMenu.items_for(:admin_submenu) do
        add_item('cloud_computing', t('cloud_computing.admin_submenu.cloud_computing'),
                 cloud_computing.admin_root_path, /^cloud_computing\/admin/)

      end


      if Octoface.role_class?(:core, 'Project')
        # define_for(model: 'Core::Project',
        #            human_model: 'Core::Project.model_name.human',
        #            human_instance: :to_s)
      end

      # Face::MyMenu.items_for(:admin_submenu) do
      #
      #   if can?(:manage, :tickets)
      #     tickets_count = Support::Ticket.where(state: [:pending, :answered_by_reporter]).count
      #     support_title = if tickets_count.zero?
      #                       t("admin_submenu.support")
      #                     else
      #                       t("admin_submenu.support_with_count.html", count: tickets_count).html_safe
      #                     end
      #
      #     add_item('tickets', support_title, support.admin_root_path, %r{support/admin/})
      #   end
      # end
    end

  end
end
