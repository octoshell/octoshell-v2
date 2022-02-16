module Perf
  module ApplicationHelper


    def brief_table(session_id, states)
      projects_with_jobs = Comparator.new(session_id).count_projects.execute.first['count']
      hash = {}
      return nil unless states.any?

      state = states.first
      state_hash = {
        'count' => projects_with_jobs
      }
      Comparator.selections.keys.each do |key|
        key_hash = {}
        key_hash['value'] = state["n_#{key}"]
        key_hash['place'] = state["n_place_#{key}"]
        state_hash[key.to_s] = key_hash
      end
      hash['ALL'] = state_hash
      states.each do |state|
        state_hash = {}
        Comparator.selections.keys.each do |key|
          key_hash = {}
          key_hash['value'] = state["s_#{key}"]
          key_hash['place'] = state["s_place_#{key}"]
          key_hash['share_value'] = state["s_share_#{key}"]
          key_hash['share_place'] = state["s_share_place_#{key}"]
          state_hash[key.to_s] = key_hash
        end
        hash[state['state']] = state_hash
      end
      hash
    end

    def expert_project_brief_stat(report)
      return nil if report.project.nil?

      project_id = report.project_id
      session_id = report.session_id
      states = Comparator.new(session_id).brief_project_stat.id_eq(project_id).execute
      return nil unless states.any?

      brief_table(session_id, states)
    end

    def perf_submenu_items
      menu = Face::MyMenu.new
      # menu.items.clear
      menu.add_item_without_key(t("perf.engine_submenu.research_areas"),
                                research_areas_main_index_path)
      menu.add_item_without_key(t("perf.engine_submenu.packages"),
                                packages_main_index_path)
      menu.add_item_without_key(t("perf.engine_submenu.experienced_users"),
                                experienced_users_main_index_path)

      menu.items(self)
    end
  end
end
