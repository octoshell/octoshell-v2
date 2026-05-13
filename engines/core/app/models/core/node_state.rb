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

    STATES    = %w[allocated idle completing drained draining down maint reserved mix].freeze
    SUBSTATES = %w[unknown maintenance pending draining].freeze

    validates :state, presence: true, inclusion: { in: STATES }
    validates :substate, allow_nil: true, inclusion: { in: SUBSTATES }

    # Returns the latest state for each node (using DISTINCT ON)
    scope :latest_per_node, lambda {
      subquery = select('DISTINCT ON (node_id) id').order('node_id, state_time DESC, id DESC')
      where(id: subquery)
    }

    # Alias for latest_per_node (current states)
    scope :current, -> { latest_per_node }

    # Returns the latest state for each node at a given time
    scope :at, lambda { |time|
      subquery = select('DISTINCT ON (node_id) id').where('state_time <= ?', time).order('node_id, state_time DESC, id DESC')
      where(id: subquery)
    }

    def to_s
      reason ? "#{state} (#{reason})" : state
    end
  end
end
