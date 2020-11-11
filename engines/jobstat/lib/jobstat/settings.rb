module Jobstat
  extend Octoface
  octo_configure :jobstat do
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
    end
  end
end
