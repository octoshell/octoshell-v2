module CloudComputing
  class Resource < ApplicationRecord
    belongs_to :resource_kind, inverse_of: :resources
    belongs_to :item, inverse_of: :resources
    has_many :resource_positions, inverse_of: :position, dependent: :destroy

    validates :resource_kind, :item, :value, presence: true
    validates :min, :max, :value, presence: true, numericality: { greater_than_or_equal_to: 0 },
                          if: :editable
    validates :min, :max, absence: true, unless: :editable

    validates :value, numericality: { only_integer: true },
                      if: :content_positive_integer?

    validates :value, presence: true,
                      numericality: { greater_than_or_equal_to: 0 }



    validate do
      if item.item_kind && resource_kind.item_kind &&
         item.item_kind != resource_kind.item_kind
        errors.add(:_destroy, :wrong_item_kind)
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

    def human_min
      "#{resource_kind.positive_integer? ? min.to_i : min} #{resource_kind.measurement}"
    end

    def human_max
      "#{resource_kind.positive_integer? ? max.to_i : max} #{resource_kind.measurement}"
    end

    def human_range
      "#{human_min} - #{human_max}"
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
      "#{value} #{resource_kind.measurement}"
    end
  end
end
