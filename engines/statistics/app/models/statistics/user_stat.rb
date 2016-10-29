module Statistics
  class UserStat < ActiveRecord::Base
    KINDS = [ :by_organization_kind,
              :by_organization_city,
              :by_msu_subdivisions ]

    include StatCollector
    include GraphBuilder

    def by_organization_kind_data
      Core::OrganizationKind.all.map do |kind|
        count = User.joins(employments: :organization).
          where(core_organizations: { kind_id: kind.id}).
          where(core_employments: { state: "active" }).count
        [kind.id, kind.name, count]
      end
    end

    def by_organization_city_data
      Core::City.all.map do |city|
        count = User.joins(employments: :organization).
          where(core_organizations: { city_id: city.id}).
          where(core_employments: { state: "active" }).count
        [city.id, city.title_ru, count] unless count.zero?
      end.compact
    end

    def by_msu_subdivisions_data
      Core::Organization.MSU.departments.order("name").map do |sub|
        count = User.with_active_projects.joins(:employments).
          where(core_employments: { state: "active", organization_department_id: sub.id }).count
        [sub.id, sub.name, count]
      end
    end
  end
end
