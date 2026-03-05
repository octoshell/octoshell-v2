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

    validates :state, presence: true

    def to_s
      reason ? "#{state} (#{reason})" : state
    end
  end
end
