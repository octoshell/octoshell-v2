module StatCollector
  extend ActiveSupport::Concern

  included do
    serialize :data

    self::KINDS.each do |kind|
      scope kind, ->{ where(kind: kind).order("created_at desc, id desc") }
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
