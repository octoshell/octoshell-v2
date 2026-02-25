module Core
  class QueueAccess < ApplicationRecord
    include StringEnum
    belongs_to :access
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :queue_accesses
    validates :access, :partition, :max_running_jobs, :max_submitted_jobs, presence: true
    string_enum %i[active blocked]

    validate do
      resource_control ||
        !access.resource_controls.map(&:queue_accesses).flatten.map(&:partition_id).include?(partition_id) ||
        errors.add(:partition_id, :exist_in_resource_control, partition: partition.name)
    end

    after_initialize do |access|
      next unless new_record?

      access.synced_with_cluster = false
      access.status ||= if !access.resource_control || access.resource_control.active?
                          'active'
                        else
                          'blocked'
                        end
      access.max_running_jobs ||= access.partition.max_running_jobs
      access.max_submitted_jobs ||= access.partition.max_submitted_jobs
    end

    after_commit :sync_access, if: :saved_change_to_status?

    def self.sync_with_cluster(id)
      QueueAccess.find(id).sync_with_cluster
    end

    def self.sync_global
      all.each(&:sync_access)
    end

    def sync_access
      Core::SshWorker.perform_async(:sync_with_cluster, id)
    end

    def sync_with_cluster(connection = nil)
      resources = if active?
                    { max_submit: max_submitted_jobs, max_jobs: max_running_jobs }
                  elsif blocked?
                    { max_submit: 0, max_jobs: 0 }
                  else
                    raise 'unknown status'
                  end
      (access.project.members.map(&:login) | access.project.removed_members.map(&:login)).each do |login|
        access.cluster.log("\t  Synchronizing queue accesses for #{login}", access.project)
        results = Core::QueueAccessSynchronizerService.new(
          access.cluster,
          { partition: partition.name, user: login, account: access.project_group_name }.merge(resources),
          connection
        ).run
        access.cluster.log("\t  #{results[2]}", access.project) if results[2].present?
      end
      access.cluster.log("\t  Synchronization of  queue accesses finished", access.project)
      update!(synced_with_cluster: true)
    end

    def block!
      update_status('blocked')
    end

    def activate!
      update_status('active')
    end

    def update_status(new_status)
      self.synced_with_cluster = false if status != new_status
      self.status = new_status
      save!
    end

    def set_status(status)
      return if resource_control

      update_status(status)
    end
  end
end
