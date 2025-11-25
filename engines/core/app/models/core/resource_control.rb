module Core
  class ResourceControl < ApplicationRecord
    include AASM
    include ::AASM_Additions
    belongs_to :access, inverse_of: :resource_controls
    has_many :resource_control_fields, inverse_of: :resource_control
    has_many :queue_accesses, inverse_of: :resource_control
    accepts_nested_attributes_for :resource_control_fields, allow_destroy: true
    validates :access, :status, presence: true

    # after_commit do
    #   check_for_exceeded
    # end

    aasm(:state, column: :status, whiny_transitions: false) do
      state :active, initial: true
      state :disabled


      event :disable do
        transitions from: :active, to: :disabled
      end

      event :activate do
        transitions from: :disabled, to: :active
      end
    end

    def exceeded?
      resource_control_fields.any?(&:exceeded?)
    end

    # def check_for_exceeded
    #   if exceeded?
    #     access.block_queue_accesses(partitions)
    #   else
    #     access.activate_queue_accesses(partitions)
    #   end
    # end

    def available_partitions
      access.cluster.partitions
    end

    def build_resource_control_fields
      return if resource_control_fields.any?

      QuotaKind.where('api_key is not null AND api_key != ""').each do |kind|
        resource_control_fields.build(quota_kind: kind)
      end
    end

  end
end
