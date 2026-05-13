# == Schema Information
#
# Table name: core_snapshots
#
#  id          :integer          not null, primary key
#  cluster_id  :integer          not null
#  captured_at :datetime         not null
#
# Indexes
#
#  index_core_snapshots_on_cluster_id  (cluster_id)
#

module Core
  class Snapshot < ApplicationRecord
    belongs_to :cluster, class_name: 'Core::Cluster'

    validates :cluster, :captured_at, presence: true

    scope :latest_first, -> { order(captured_at: :desc) }

    # Returns node states that were actual at the moment of this snapshot
    def node_states_at
      Core::NodeState.at(captured_at).joins(:node).where(core_nodes: { cluster_id: cluster_id })
    end
  end
end
