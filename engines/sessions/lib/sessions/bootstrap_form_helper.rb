module Sessions
  class BootstrapFormHelper < Octoface::BootstrapFormHelper

    def sessions_id_in
      m_options = { include_blank: true }.merge(options)
      f.collection_select prefix + 'sessions_id_in',
                          Sessions::Session.all,
                          :id, :description,
                          m_options, multiple: true
    end

    def reports_state_in
      m_options = { include_blank: true }.merge(options)
      f.select prefix + 'reports_state_in',
               Sessions::Report.human_state_names_with_original,
               m_options, multiple: true
    end

    def surveys_state_in
      m_options = { include_blank: true }.merge(options)
      f.select prefix + 'surveys_state_in',
               Sessions::UserSurvey.human_state_names_with_original,
               m_options, multiple: true

    end


    def projects_state_in
      m_options = { include_blank: true }.merge(options)
      f.select prefix + 'projects_state_in',
               Core::Project.human_state_names_with_original,
               m_options, multiple: true
    end

    def available_projects_available_clusters_id_in
      m_options = { include_blank: true }.merge(options)
      f.collection_select prefix + 'available_projects_available_clusters_id_in',
                          Core::Cluster.all, :id, :name, m_options, multiple: true
    end
  end
end
