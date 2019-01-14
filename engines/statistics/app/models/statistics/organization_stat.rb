module Statistics
  class OrganizationStat < ActiveRecord::Base
    KINDS = [ :by_kind,
              :by_city ].freeze

    include StatCollector
    include GraphBuilder

    def by_kind_data
      Core::OrganizationKind.all.map do |kind|
        [kind.id, kind.name, kind.organizations.count]
      end
    end

    def by_city_data
      Core::City.all.map do |city|
        count = Core::Organization.where(city_id: city.id).count
        [city.id, city.title_ru, count] unless count.zero?
      end.compact
    end
  end
end
