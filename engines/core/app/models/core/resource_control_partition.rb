module Core
  class ResourceControlPartition < ApplicationRecord
    belongs_to :access
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :resource_control_partitions
    validates :partition, :max_running_jobs, :max_submitted_jobs, presence: true

    validate do
      errors.add(:partition_id, :invalid) unless access.cluster.partitions.include? partition
    end

    after_initialize do |record|
      next unless new_record?

      record.max_running_jobs ||= access.partition.max_running_jobs
      record.max_submitted_jobs ||= access.partition.max_submitted_jobs
    end
  end
end
