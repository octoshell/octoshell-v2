module Core
  class ResourceControlPartition < ApplicationRecord
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :resource_control_partitions
    validates :partition, :max_running_jobs, :max_submitted_jobs, presence: true

    validate do
      errors.add(:partition_id, :invalid) unless resource_control.access.cluster.partitions.include? partition
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

    def cluster
      resource_control.access.cluster
    end

    def logins
      resource_control.access.project.members.map(&:login) |
        resource_control.access.project.removed_members.map(&:login)
    end

    def access
      resource_control.access
    end

    def sync_with_cluster(max_submit, max_jobs, connection = nil)
      access.cluster.log("\t Synchronizing queue accesses in #{partition.name}", access.project)

      command = "\t sudo /usr/octo/add_assoc.sh -p #{partition.name} \
                                -u #{logins.join(',')} \
                                -a #{access.project_group_name} \
                                -s #{max_submit} -j #{max_jobs}".squeeze(' ')
      access.cluster.log(command, access.project)

      results = cluster.execute(command, connection)

      access.cluster.log(results[2], access.project) if results[2].present?
      access.cluster.log("\t Synchronization of queue accesses finished in #{partition.name}", access.project)
    end
  end
end
