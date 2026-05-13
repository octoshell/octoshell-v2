# == Schema Information
#
# Table name: core_node_states
#
#  id         :integer          not null, primary key
#  node_id    :integer          not null
#  state      :string(255)      not null
#  reason     :text
#  state_time :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_core_node_states_on_node_id   (node_id)
#  index_core_node_states_on_state_time  (state_time)
#

module Core
  class NodeState < ApplicationRecord
    belongs_to :node, class_name: 'Core::Node'
    belongs_to :snapshot, class_name: 'Core::Snapshot', optional: true

    STATES    = %w[alloc idle comp drain drng down maint reserved mix].freeze
    SUBSTATES = %w[unknown maintenance pending draining].freeze

    validates :state, presence: true, inclusion: { in: STATES }
    validates :substate, allow_nil: true, inclusion: { in: SUBSTATES }

    scope :current, -> { where(snapshot_id: Snapshot.select(:id).order(captured_at: :desc).limit(1)) }
    scope :at, ->(time) { where(snapshot: Snapshot.where('captured_at <= ?', time).order(captured_at: :desc).limit(1)) }

    def to_s
      reason ? "#{state} (#{reason})" : state
    end
  end
end
