module CloudComputing
  class ResourcePosition < ApplicationRecord
    belongs_to :position, inverse_of: :resource_positions, autosave: true
    belongs_to :resource, -> { where(editable: true) }, inverse_of: :resource_positions
    validates :position, :resource, :value, presence: true
    validates :value, numericality: { only_integer: true }, if: :only_integer?

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
      if resource.min >= value && value >= resource.max &&
         position.holder.is_a?(CloudComputing::Request)
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
