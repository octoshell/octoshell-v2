module Core
  class QueueAccess < ApplicationRecord
    belongs_to :access
    belongs_to :partition
    belongs_to :resource_control, inverse_of: :queue_accesses
    validates :access, :partition, presence: true

    before_create do
      self.allowed = true
      self.synced_with_cluster = false
    end

    def block
      update!(allowed: false, synced_with_cluster: false)
    end

    def activate
      update!(allowed: true, synced_with_cluster: false)
    end

  end
end
