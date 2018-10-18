require 'net/http'
require 'net/https'
require 'uri'

module Jobstat
  module ApplicationHelper
    def jobstat_admin_submenu_items
      menu = Face::Menu.new
      menu.items.clear
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.jobs_total"),
                                        url: [:admin, :tickets],
                                        regexp: /tickets/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.jobs_by_users"),
                                        url: [:admin, :reply_templates],
                                        regexp: /reply_templates/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.jobs_by_tags"),
                                        url: [:admin, :tags],
                                        regexp: /tags/}))
      menu.add_item(Face::MenuItem.new({name: t("engine_submenu.jobs_by_projects"),
                                        url: [:admin, :topics],
                                        regexp: /topics/}))
      menu.items
    end

    def link_to_attachment(record)
      if record.attachment?
        "#{link_to File.basename(record.attachment.url), record.attachment.url, target: :blank} #{number_to_human_size(record.attachment.size)}".html_safe
      end
    end

    def root_path
      main_app.root_path
    end

  end
end
