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
    self.table_name = 'core_snapshots'

    belongs_to :cluster, class_name: 'Core::Cluster'
    has_many :node_states, class_name: 'Core::NodeState', foreign_key: :snapshot_id, dependent: :destroy

    validates :cluster, :captured_at, presence: true

    scope :latest_first, -> { order(captured_at: :desc) }
  end
end
