module Core
  extend Octoface
  octo_configure :core do
    add('Project')
    add('Organization')
    add('Member')
    add_ability(:manage, :projects, 'superadmins')
    add_controller_ability(:manage, :projects, 'admin/projects',
                           'admin/project_kinds', 'admin/direction_of_sciences',
                           'admin/critical_technologies', 'admin/research_areas',
                           'admin/group_of_research_areas')
    add_ability(:manage, :sureties, 'superadmins')
    add_controller_ability(:manage, :sureties, 'admin/sureties')
    add_ability(:manage, :requests, 'superadmins')
    add_controller_ability(:manage, :requests, 'admin/requests')
    add_ability(:manage, :organizations, 'superadmins')
    add_controller_ability(:manage, :organizations, 'admin/organizations', 'admin/organization_kinds')
    add_ability(:manage, :clusters, 'superadmins')
    add_controller_ability(:manage, :clusters, 'admin/clusters', 'admin/cluster_logs', 'admin/quota_kinds')
    add_ability(:manage, :geography, 'superadmins')
    add_controller_ability(:manage, :geography, 'admin/cities', 'admin/countries')
    add_ability(:manage,  :notices, 'superadmins')
    add_controller_ability(:manage, :notices, 'admin/job_notifications', 'admin/job_notification_global_defaults', 'admin/user_job_notifications')
    add_routes do
      mount Core::Engine, :at => "/core"
    end
    module ::Core::NoticeHandlers
      def self.call
        Core::Notice.register_def_nil_kind_handler
        Core::Notice.register_kind 'jobstat' do |notice, user, params, request|
          nil
        end
      end
    end

    after_init do
      Core.user_class = '::User'
      Face::MyMenu.items_for(:user_submenu) do
        add_item('projects', t('user_submenu.projects'), core.projects_path, 'core/projects')
        notices_count = Core::Notice.get_count_for_user current_user
        if notices_count.zero?
          add_item('notices', t('core.notice.notices_menu'), core.notices_path,
                   %r{^notices})
        else
          add_item(
            'notices',
            t('core.notice.notices_menu_count.html', count: notices_count).html_safe,
            core.notices_path,
            %r{^notices})
        end

      end
      Face::MyMenu.items_for(:admin_submenu) do
        if can? :manage, :projects
          add_item('projects', t('admin_submenu.projects'),
                   core.admin_projects_path,
                   'core/admin/projects')
        end

        sureties_count = Core::Surety.where(state: :confirmed).count
        sureties_title = if sureties_count.zero?
                           t("admin_submenu.sureties")
                         else
                           t("admin_submenu.sureties_with_count.html", count: sureties_count).html_safe
                         end

         add_item_if_may('sureties', sureties_title,
                  core.admin_sureties_path,
                  'core/admin/sureties')

         requests_count = Core::Request.where(state: :pending).count
         requests_title = if requests_count.zero?
                          t("admin_submenu.requests")
                        else
                          t("admin_submenu.requests_with_count.html", count: requests_count).html_safe
                        end
          add_item_if_may('requests', requests_title,
                   core.admin_requests_path,
                   'core/admin/requests')


            add_item_if_may('organizations', t("admin_submenu.organizations"), core.admin_organizations_path, 'core/admin/organizations')

            add_item_if_may('clusters', t("admin_submenu.clusters"), core.admin_clusters_path, 'core/admin/clusters')

            add_item_if_may('cluster_logs', t("admin_submenu.cluster_logs"), core.admin_cluster_logs_path, 'core/admin/cluster_logs')

            add_item_if_may('quota_kinds', t("admin_submenu.quota_kinds"), core.admin_quota_kinds_path, 'core/admin/quota_kinds')

            add_item_if_may('project_kinds', t("admin_submenu.project_kinds"), core.admin_project_kinds_path, 'core/admin/project_kinds')
            #projects
            add_item_if_may('organization_kinds', t("admin_submenu.organization_kinds"), core.admin_organization_kinds_path, 'core/admin/organization_kinds')
            #organization

            add_item_if_may('direction_of_sciences', t("admin_submenu.direction_of_sciences"), core.admin_direction_of_sciences_path, 'core/admin/direction_of_sciences')

            add_item_if_may('critical_technologies', t("admin_submenu.critical_technologies"), core.admin_critical_technologies_path, 'core/admin/critical_technologies')

            add_item_if_may('research_areas', t("admin_submenu.research_areas"), core.admin_research_areas_path, 'core/admin/research_areas')

            add_item_if_may('countries', t("admin_submenu.countries"), core.admin_countries_path, 'core/admin/countries')
            add_item_if_may('cities', t("admin_submenu.cities"), core.admin_cities_path, 'core/admin/cities')

            add_item_if_may('notices', t("admin_submenu.job_notifications"), core.admin_job_notifications_path, 'core/admin/job_notifications')

            if can?(:manage, :notices)
              add_item('notices', t('core.notice.notices_menu'),
                       core.admin_notices_path,'core/admin/notices')
            end

      end
      set :support do
        ticket_field(key: :cluster,
                     admin_link: proc { |id| can?(:manage, :clusters) ? core.admin_cluster_path(id) : nil },
                     user_query: proc { Cluster.where(available_for_work: true) },
                     admin_query: proc { Cluster.all })

        ticket_field(key: :project,
                     # метод для отображения объекта, если не указано, то :to_s
                     human: :title,
                     # Если есть права, показать в админке значение со ссылкой на проект
                     admin_link: proc { |id| core.admin_project_path(id) },
                     # Если есть права, показать в рабочем кабнете ссылку
                     user_link: proc { |id| core.project_path(id) },
                     # Запрос для пользовательской версии
                     user_query: proc { |user| user.projects },
                     # Запрос для админки(это можно будет убрать, так как есть admin_source)
                     admin_query: proc { Core::Project.all },
                     # Поиск по аяксу в админке
                     admin_source: proc { core.finder_admin_projects_path })


      end
    end
  end
end
