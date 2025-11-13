module Core
  class ResourceControl < ApplicationRecord
    include AASM
    include ::AASM_Additions
    belongs_to :access
    has_many :resource_control_fields, inverse_of: :resource_control
    has_and_belongs_to_many :partitions
    accepts_nested_attributes_for :resource_control_fields, allow_destroy: true
    validates :access, :status, presence: true
    validates :access_id, uniqueness: true, unless: :archived?

    aasm(:status) do
      state :active, initial: true
      state :blocked
      state :archived

      event :block do
        transitions from: %i[active blocked], to: :blocked
      end

      event :activate do
        transitions from: %i[active blocked], to: :active
      end

      event :archive do
        transitions from: %i[active blocked], to: :archived
      end
    end


    def available_partitions
      access.cluster.partitions
    end

    # def partition_ids_setter
    #   queue_accesses.reject(&:marked_for_destruction?).map(&:partition_id)
    # end
    #
    # def partition_ids_setter=(ids)
    #   ids = (ids || []).select(&:present?).map(&:to_i)
    #   ids.each do |id|
    #     queue_accesses.detect { |a| a.partition_id == id } ||
    #       queue_accesses.build(partition_id: id)
    #   end
    #   queue_accesses.reject { |a| ids.include?(a.partition_id) }
    #                 .each(&:mark_for_destruction)
    # end


    def current

    end

    def build_resource_control_fields
      # part_ids = QueueAccess.joins(resource_control_field: :resource_control)
      #                       .where(core_resource_controls: { access_id: id })
      #                       .distinct.pluck(:partition_id)
      # cur_part_ids = resource_control_fields.map(&:queue_accesses).flatten
      #                                       .map(&:partition_id).uniq

      unless resource_control_fields.any?
        resource_control_fields.build(quota_kind: QuotaKind.last)
      end


      # field = resource_control_fields.to_a.last
      # access.cluster.partitions.each do |partition|
      #   next if (part_ids | cur_part_ids).include? partition.id
      #
      #   field.queue_accesses.build(partition: partition)
      #
      # end
    end

  end
end
