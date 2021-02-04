module CloudComputing
  class ResourceItem < ApplicationRecord
    belongs_to :item, inverse_of: :resource_items, autosave: true
    belongs_to :resource, -> { where(editable: true) }, inverse_of: :resource_items
    has_one :resource_kind, through: :resource

    validates :item, :resource, :value, presence: true
    validates :value, numericality: { only_integer: true }, if: :only_integer?
    validates :value, inclusion: { in: ['0', '1'] }, if: proc { |r|
      r.resource_kind.boolean?
    }

    scope :with_identity, (lambda do
      joins(resource: :resource_kind).where.not(cloud_computing_resource_kinds: {
        identity: ['', nil] })
    end)

    scope :where_identity, (lambda do |identity|
      joins(resource: :resource_kind).where(cloud_computing_resource_kinds: {
        identity: identity })
    end)

    before_validation do
      self.value = value.to_i if only_integer?
    end

    validate do
      next if resource_kind.boolean?

      if resource.min >= value.to_f && value.to_f >= resource.max &&
         item.holder.is_a?(CloudComputing::Request)
        errors.add(:value)
      end
    end

    def only_integer?
      resource.resource_kind.positive_integer?
    end

    def human_value
      only_integer? ? value.to_i : value
    end

    def name_value
      measurement = resource.resource_kind.measurement
      if measurement.present?
        "<b>#{resource.resource_kind.name}:</b> #{human_value} #{measurement}"
      else
        "<b>#{resource.resource_kind.name}:</b> #{human_value}"
      end
    end

  end
end
