module StatCollector
  extend ActiveSupport::Concern
  module ClassMethods
    def kinds_to_classes
      {
        by_organization_kind: Core::OrganizationKind.all,
        by_organization_city: Core::City.all,
        by_directions_of_science: Core::DirectionOfScience.all,
        by_research_areas: Core::ResearchArea.all,
        by_critical_technologies: Core::CriticalTechnology.all,
        by_state: :human_state_names_with_original
      }
    end
  end
  included do
    serialize :data

    self::KINDS.each do |kind|
      scope kind, -> { where(kind: kind).order("created_at desc, id desc") }
    end

    def self.calculate_stats
      transaction do
        self::KINDS.each do |kind|
          new { |c| c.kind = kind }.dump
        end
      end
    end

    def self.human_kind_name(kind)
      I18n.t("statistics.#{kind}")
    end
  end

  def dump
    self.data = send("#{kind}_data")
    save!
  end
end
