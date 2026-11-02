# == Schema Information
#
# Table name: core_accesses
#
#  id                       :integer          not null, primary key
#  deny_unlisted_partitions :boolean          default(FALSE), not null
#  project_group_name       :string(255)
#  state                    :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  cluster_id               :integer          not null
#  project_id               :integer          not null
#
# Indexes
#
#  index_core_accesses_on_cluster_id                 (cluster_id)
#  index_core_accesses_on_project_id                 (project_id)
#  index_core_accesses_on_project_id_and_cluster_id  (project_id,cluster_id) UNIQUE
#

module Core
  class Access < ApplicationRecord
    SYNC_LOCK_WAIT_SECONDS = 30
    SYNC_LOCK_EXPIRE_SECONDS = 30.minutes.to_i

    belongs_to :project
    belongs_to :cluster

    has_many :fields, class_name: 'AccessField', inverse_of: :access, dependent: :destroy
    accepts_nested_attributes_for :fields
    validates :project, :cluster, presence: true
    has_many :resource_controls, inverse_of: :access
    has_many :resource_users, inverse_of: :access
    has_many :resource_control_partitions, through: :resource_controls

    accepts_nested_attributes_for :resource_controls,
                                  :resource_users, allow_destroy: true

    include AASM
    include ::AASM_Additions
    aasm :state, column: :state do
      state :opened, initial: true
      state :closed

      event :close do
        transitions from: :opened, to: :closed
      end

      event :reopen do
        transitions from: :closed, to: :opened
      end
    end

    def quota_resources_info
      fields.map(&:to_s).join(' | ')
    end

    def log(message)
      logger.info message
    end

    def to_s
      "#{project.title} | #{cluster.name}"
    end

    def build_form_defaults
      resource_controls.each(&:build_resource_control_defaults_for_form)
    end

    # Требования к теребоньке.
    #
    # Выполнять все действия по одному ssh-соединению
    # логировать все команды и результаты выполнения
    # синхронизовать проект
    # синхронизовать участников проекта

    def synchronize!
      with_sync_lock do
        Synchronizer.new(self).run!
      end
    end

    def synchronize_resource_controls!
      with_sync_lock do
        Synchronizer.new(self).run_resource_controls!
      end
    end

    def enqueue_resource_controls_synchronize
      ::AccessSynchronizer.perform_async(id, :resource_controls)
    end

    def listed_partition_ids
      resource_control_partitions.reorder(nil)
                                 .distinct
                                 .pluck('core_resource_control_partitions.partition_id')
    end

    def unlisted_partitions
      ids = listed_partition_ids
      ids.empty? ? cluster.partitions : cluster.partitions.where.not(id: ids)
    end

    def sync_partition_access(partition, max_submitted_jobs, max_running_jobs, connection)
      cluster.log("\t Synchronizing queue accesses in #{partition.name}", project)
      command = partition_access_command(partition, max_submitted_jobs, max_running_jobs)
      cluster.log(command, project)

      log_partition_access_result(cluster.execute(command, connection))
      cluster.log("\t Synchronization of queue accesses finished in #{partition.name}", project)
    end

    private

    def log_partition_access_result(results)
      cluster.log(results[2], project) if results[2].present?
    end

    def partition_access_command(partition, max_submitted_jobs, max_running_jobs)
      "\t sudo /usr/octo/add_assoc.sh -p #{partition.name} \
                                -u #{project_logins.join(',')} \
                                -a #{project_group_name} \
                                -s #{max_submitted_jobs} -j #{max_running_jobs}".squeeze(' ')
    end

    def project_logins
      project.members.map(&:login) | project.removed_members.map(&:login)
    end

    def with_sync_lock
      RedisMutex.with_lock(sync_lock_key,
                           block: SYNC_LOCK_WAIT_SECONDS,
                           expire: SYNC_LOCK_EXPIRE_SECONDS) do
        reload
        yield
      end
    end

    def sync_lock_key
      "core:access_sync:#{id}"
    end
  end
end
