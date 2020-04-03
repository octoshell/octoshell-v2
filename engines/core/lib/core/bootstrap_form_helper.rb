module Core
  class BootstrapFormHelper < Octoface::BootstrapFormHelper

    def project_kind_id_eq
      options[:label] ||= Core::ProjectKind.model_name.human
      options[:include_blank] ||= true
      f.collection_select(prefix + 'kind_id_eq', Core::ProjectKind.all,
                          :id, :name, options, html_options)
    end

    def project_id_eq
      autocomplete f, name: prefix + 'id_eq', label: Core::Project.human_attribute_name(:title),
                      source: core.projects_path
    end

    def organization_kind_id_eq
      f.collection_select(prefix + 'kind_id_eq',
                          Core::OrganizationKind.order(Core::OrganizationKind
                          .current_locale_column(:name)),
                          :id, :name, label: Core::OrganizationKind.model_name.human,
                          include_blank: true)

    end

    def organization_id_eq
      f.collection_select prefix + 'organization_id_eq', Core::Organization.order(:name),
                          :id, :full_name,
                          label: Core::Project.human_attribute_name(:organization),
                          include_blank: true
    end

    def project_state_in
      f.select prefix + 'state_in', Core::Project.human_state_names_with_original,
               { label: Core::Project.human_attribute_name(:state), include_blank: true },
               { multiple: true }
    end

    def owner_id_eq
      f.collection_select(prefix + 'owner_id_eq',
                          User.joins(:account_owners).preload(:profile).distinct,
                          :id, :full_name_with_email,
                          label: Core::Project.human_attribute_name("owner"),
                          include_blank: true)
    end

    def autocomplete_project_id_eq
      options[:source] ||= core.projects_path
      f.autocomplete_field prefix + 'project_id_eq', options do |val|
        Core::Project.find(val).title
      end
    end

    def project_group_of_research_areas_id_in
      options[:include_blank] ||= true
      f.collection_select prefix + 'project_group_of_research_areas_id_in',
                          Core::GroupOfResearchArea.order_by_name,
                          :id, :name, options, multiple: true
    end

    def project_research_areas_id_in
      options[:include_blank] ||= true
      f.grouped_collection_select prefix + 'project_research_areas_id_in',
                                  Core::GroupOfResearchArea.order_by_name_with_areas,
                                  :research_areas, :name, :id, :name,
                                  options, multiple: true
    end

    def usual_project_research_areas_id_in
      options[:include_blank] ||= true
      options[:label] ||= ResearchArea.model_name.human

      f.collection_select prefix + 'project_research_areas_id_in',
                          ResearchArea.all, :id, :name, options,
                          {multiple: true}
    end

    def project_critical_technologies_id_in
      options[:include_blank] ||= true
      f.collection_select prefix + 'project_critical_technologies_id_in',
                          CriticalTechnology.order_by_name, :id, :name,
                          options, multiple: true
    end

    def project_direction_of_sciences_id_in
      options[:include_blank] ||= true
      f.collection_select prefix + 'project_direction_of_sciences_id_in',
                          DirectionOfScience.order_by_name, :id, :name,
                          options, multiple: true
    end

    def employments_organization_id_in
      m_options = { label: Core::Employment.model_name.human,
                  source: core.organizations_path,
                  include_blank: true }.merge(options)
      f.autocomplete_field(prefix + 'employments_organization_id_in',
                           m_options) do |val|
        Core::Organization.find(val).name_with_id
      end
    end

    def accounts_id_in
      m_options = { label: Core::Member.human_attribute_name(:login),
                  source: core.admin_members_path }.merge(options)
      f.autocomplete_field prefix + 'accounts_id_in', m_options,
                          'redirect-url': '/admin/users/{{user_id}}'
    end

    def owned_projects_state_in
      m_options = { include_blank: true }.merge(options)
      f.select prefix + 'owned_projects_state_in',
               Core::Project.human_state_names_with_original,
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
