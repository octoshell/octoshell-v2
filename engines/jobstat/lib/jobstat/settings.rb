module Jobstat
  extend Octoface
  octo_configure :jobstat do
    add_ability(:show_jobs, :projects, 'superadmins')
    add_controller_ability(:show_jobs, :projects, 'admin/stats')

    add_routes do
      mount Jobstat::Engine, :at => "/jobstat"
    end
    after_init do
      Face::MyMenu.items_for(:user_submenu) do
        add_item('jobstat_summary', t("user_submenu.job_stat"), jobstat.account_summary_show_path,
                 %r{^jobstat/account_summary})
        add_item('jobstat_list', t("user_submenu.job_table"), jobstat.account_list_index_path,
                 %r{^jobstat/account_list})
      end

      Face::MyMenu.items_for(:admin_submenu) do
        add_item_if_may('job_stats', t("admin_submenu.job_stats"),
                        jobstat.admin_stats_by_project_path,
                        'jobstat/admin/stats')
      end

    end
  end
end
