module Core
  class QueueAccess < ApplicationRecord
    belongs_to :resource_control, inverse_of: :queue_accesses
    belongs_to :partition
    validates :resource_control, :partition, presence: true
    validates :resource_control_id, uniqueness: { scope: :partition_id }
  end
end
