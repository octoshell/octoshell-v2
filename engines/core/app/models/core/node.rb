# == Schema Information
#
# Table name: core_nodes
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  cluster_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_core_nodes_on_cluster_id_and_name  (cluster_id,name) UNIQUE
#

module Core
  class Node < ApplicationRecord
    belongs_to :cluster, class_name: 'Core::Cluster', inverse_of: :nodes
    has_many :node_partitions, class_name: 'Core::NodePartition', dependent: :destroy
    has_many :partitions, through: :node_partitions
    has_many :node_states, class_name: 'Core::NodeState', dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :cluster_id }

    # Returns the last state of the node
    def last_state
      node_states.order(created_at: :desc).first
    end

    # Returns the current state of the node
    def current_state
      last_state&.state
    end

    # Returns the current reason of the node
    def current_reason
      last_state&.reason
    end

    # Normalizes state: treats 'allocated' and 'idle' as equivalent
    # @param state [String, nil] state to normalize
    # @return [String, nil] normalized state
    def self.normalize_state(state)
      return state if state.blank?

      # Treat 'allocated' and 'idle' as equivalent
      # Keep SLURM suffixes (~, #, *) for accurate state tracking
      %w[allocated].include?(state) ? 'idle' : state
    end

    # Instance method delegate to class method for backward compatibility
    def normalize_state(state)
      self.class.normalize_state(state)
    end

    def to_s
      name
    end
  end
end
