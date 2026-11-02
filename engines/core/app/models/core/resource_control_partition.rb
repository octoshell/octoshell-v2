module Core
  class ResourceControlPartition < ApplicationRecord
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :resource_control_partitions
    validates :partition, :max_running_jobs, :max_submitted_jobs, presence: true

    validate do
      errors.add(:partition_id, :invalid) unless resource_control.access.cluster.partitions.include? partition
    end

    before_destroy do
      throw(:abort) unless resource_control.pending? || destroyed_by_association.present?
    end

    after_initialize do |record|
      next unless new_record?

      record.max_running_jobs ||= record.partition.max_running_jobs
      record.max_submitted_jobs ||= record.partition.max_submitted_jobs
    end

    def to_s
      partition.name.to_s
    end

    def block(connection = nil)
      sync_with_cluster(0, 0, connection)
    end

    def activate(connection = nil)
      sync_with_cluster(max_submitted_jobs, max_running_jobs, connection)
    end

    private

    def access
      resource_control.access
    end

    def sync_with_cluster(max_submit, max_jobs, connection = nil)
      access.sync_partition_access(partition, max_submit, max_jobs, connection)
    end
  end
end
