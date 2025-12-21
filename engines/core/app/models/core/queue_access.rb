module Core
  class QueueAccess < ApplicationRecord
    include StringEnum
    belongs_to :access
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :queue_accesses
    validates :access, :partition, :max_running_jobs, :max_submitted_jobs, presence: true
    string_enum %i[active blocked disabled]

    after_initialize({ if: :new_record? }) do |access|
      access.status ||= 'active'
      access.synced_with_cluster = false
      access.max_running_jobs ||= access.partition.max_running_jobs
      access.max_submitted_jobs ||= access.partition.max_submitted_jobs
    end

    def block!
      update!(status: 'blocked', synced_with_cluster: false) if active?
    end

    def activate!
      update!(status: 'active', synced_with_cluster: false) if blocked?
    end

    def set_status(status)
      return if resource_control

      self.status = status
      self.synced_with_cluster = false if status != 'disabled'
      save!
    end


  end
end
