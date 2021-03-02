module CloudComputing
  class Resource < ApplicationRecord
    belongs_to :resource_kind, inverse_of: :resources
    belongs_to :template, inverse_of: :resources
    has_many :resource_items, inverse_of: :position, dependent: :destroy

    validates :resource_kind, :template, :value, presence: true
    validates :min, :max, :value, presence: true, numericality: { greater_than_or_equal_to: 0 },
                          if: :editable_number?
    validates :min, :max, absence: true, unless: :editable_number?
    # validates :max, inclusion: 1..2

    validates :value, numericality: { only_integer: true },
                      if: :content_positive_integer?

    validates :value, presence: true,
                      numericality: { greater_than_or_equal_to: 0 }


    validates :value, inclusion: { in: ['0', '1'] }, if: proc { |r|
      r.resource_kind.boolean?
    }



    validate do
      # validates :max, inclusion: 1..2
      # errors.add(:max, :less_than_or_equal_to, count: 1..3)
      if template.template_kind && resource_kind.template_kind &&
         template.template_kind != resource_kind.template_kind
        errors.add(:_destroy, :wrong_template_kind)
      end

      if min && max && min > max
        errors.add(:min, :invalid)
      end
    end


    scope :where_identity, (lambda do |identity|
      joins(:resource_kind).where(cloud_computing_resource_kinds: {
        identity: identity })
    end)

    def content_positive_integer?
      resource_kind.positive_integer?
    end


    def processed_min
      resource_kind.positive_integer? ? min.to_i : min
    end

    def processed_max
      resource_kind.positive_integer? ? max.to_i : max
    end

    def human_min
      "#{resource_kind.positive_integer? ? min.to_i : min} #{resource_kind.measurement}"
    end

    def human_max
      "#{resource_kind.positive_integer? ? max.to_i : max} #{resource_kind.measurement}"
    end

    def human_range
      "#{human_min} - #{human_max}"
    end

    def editable_number?
      editable && !resource_kind.boolean?
    end

    # def name_value
    #   "<b>#{resource_kind.name_with_measurement}:</b> #{human_value}"
    # end

    def name_value
      measurement = resource_kind.measurement
      if measurement.present?
        "<b>#{resource_kind.name}:</b> #{human_value} #{measurement}"
      else
        "<b>#{resource_kind.name}:</b> #{human_value}"
      end
    end

    def human_value
      only_integer? ? value.to_i : value
    end

    def only_integer?
      resource_kind.positive_integer?
    end

    def value_with_measurement
      if resource_kind.boolean?
        I18n.t(value == '1')
      else
        "#{value} #{resource_kind.measurement}"
      end
    end
  end
end
