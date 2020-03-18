module Core
  extend Octoface
  octo_configure :core do
    add('Project')
    add('Cluster')
    add('Organization')
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
    # set :support do
    #   ticket_field(key: :cluster,
    #                admin_link: proc { |id| can?(:manage, :clusters) ? core.admin_cluster_path(id) : nil },
    #                user_query: proc { Cluster.where(available_for_work: true) },
    #                admin_query: proc { Cluster.all })
    #
    #   ticket_field(key: :project,
    #                # метод для отображения объекта, если не указано, то :to_s
    #                 human: :title,
    #                # Если есть права, показать в админке значение со ссылкой на проект
    #                admin_link: proc { |id| core.admin_project_path(id) },
    #                # Если есть права, показать в рабочем кабнете ссылку
    #                user_link: proc { |id| core.project_path(id) },
    #                # Запрос для пользовательской версии
    #                user_query: proc { |user| user.projects },
    #                # Запрос для админки(это можно будет убрать, так как есть admin_source)
    #                admin_query: proc { Core::Project.all },
    #                # Поиск по аяксу в админке
    #                admin_source: proc { core.projects_path })
    #
    #
    # end
  end
end
