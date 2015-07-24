module Statistics
  class ProjectStat < ActiveRecord::Base
    KINDS = [ :by_organization_kind,
              :by_organization_city,
              :by_msu_subdivisions,
              :by_directions_of_science,
              :by_research_areas,
              :by_critical_technologies,
              :by_state ]

    include StatCollector
    include GraphBuilder

    def by_organization_kind_data
      Core::OrganizationKind.all.map do |kind|
        count = Core::Project.with_state(:active).joins(:organization).
          where(core_organizations: { kind_id: kind.id }).
          count
        [kind.id, kind.name, count]
      end
    end

    def by_organization_city_data
      Core::City.all.map do |city|
        count = Core::Project.with_state(:active).joins(:organization).
          where(core_organizations: { city_id: city.id }).
          count
        [city.id, city.title_ru, count] unless count.zero?
      end.compact
    end

    def by_msu_subdivisions_data
      Core::Organization.MSU.departments.order("name").map do |sub|
        count = Core::Project.with_state(:active).joins(owner: :employments).
          where(core_employments: { state: "active", organization_department_id: sub.id }).count
        [sub.id, sub.name, count]
      end
    end

    def by_directions_of_science_data
      Core::DirectionOfScience.all.map do |dos|
        count = Core::Project.with_state(:active).joins("join core_direction_of_sciences_per_projects dosp on dosp.project_id = core_projects.id and dosp.direction_of_science_id = #{dos.id}").
          count
        count += Core::Project.with_state(:blocked).joins("join core_direction_of_sciences_per_projects dosp on dosp.project_id = core_projects.id and dosp.direction_of_science_id = #{dos.id}").
          count
        count += Core::Project.with_state(:suspended).joins("join core_direction_of_sciences_per_projects dosp on dosp.project_id = core_projects.id and dosp.direction_of_science_id = #{dos.id}").
          count

          [dos.id, dos.name, count]
      end
    end

    def by_research_areas_data
      Core::ResearchArea.all.map do |area|
        count = Core::Project.with_state(:active).joins("join core_research_areas_per_projects rap on rap.project_id = core_projects.id and rap.research_area_id = #{area.id}").
          count
        count += Core::Project.with_state(:blocked).joins("join core_research_areas_per_projects rap on rap.project_id = core_projects.id and rap.research_area_id = #{area.id}").
          count
        count += Core::Project.with_state(:suspended).joins("join core_research_areas_per_projects rap on rap.project_id = core_projects.id and rap.research_area_id = #{area.id}").
          count

          [area.id, area.name, count]
      end
    end

    def by_critical_technologies_data
      Core::CriticalTechnology.all.map do |tech|
        count = Core::Project.with_state(:active).joins("join core_critical_technologies_per_projects ctp on ctp.project_id = core_projects.id and ctp.critical_technology_id = #{tech.id}").
          count
        count += Core::Project.with_state(:blocked).joins("join core_critical_technologies_per_projects ctp on ctp.project_id = core_projects.id and ctp.critical_technology_id = #{tech.id}").
          count
        count += Core::Project.with_state(:suspended).joins("join core_critical_technologies_per_projects ctp on ctp.project_id = core_projects.id and ctp.critical_technology_id = #{tech.id}").
          count

          [tech.id, tech.name, count]
      end
    end

    def by_state_data
      Core::Project.human_state_names.map do |human_name, state|
        [state, human_name, Core::Project.where(state: state).count]
      end
    end
  end
end
