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

    validate do
      if item.item_kind && resource_kind.item_kind &&
         item.item_kind != resource_kind.item_kind
        errors.add(:_destroy, :wrong_item_kind)
      end

      if min && max && min > max
        errors.add(:min, :invalid)
      end
    end

    def content_positive_integer?
      resource_kind.positive_integer?
    end

    def value_with_measurement
      "#{value} #{resource_kind.measurement}"
    end
  end
end
