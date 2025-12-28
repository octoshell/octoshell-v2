module CloudComputing
  class ResourceKind < ApplicationRecord
    old_enum content_type: %i[positive_integer decimal boolean]
    translates :name, :description, :measurement, :help
    validates_translated :name, presence: true
    has_many :resources, inverse_of: :resource_kind, dependent: :destroy
    belongs_to :template_kind, inverse_of: :resource_kinds
    validates :template_kind, :content_type, presence: true

    def self.seed!
      ResourceKind.where(identity: 'MEMORY').first_or_create! do |resource_kind|
        resource_kind.name_ru = 'Оперативная память'
        resource_kind.name_en = 'Main memory'
        resource_kind.measurement_ru = 'МБ'
        resource_kind.measurement_en = 'MB'
      end

      ResourceKind.where(identity: 'CPU').first_or_create! do |resource_kind|
        resource_kind.name_ru = 'CPU'
        resource_kind.name_en = 'CPU'
      end
    end

    def human_content_type
      self.class.human_content_type content_type
    end


    def self.human_content_type(enum_value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.content_types.#{enum_value}")
    end

    def self.human_content_types
      content_types.keys.map do |c|
        [human_content_type(c), c]
      end
    end


    def name_with_measurement
      if measurement
        "#{name}(#{measurement})"
      else
        name
      end
    end
  end
end
