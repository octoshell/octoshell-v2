# This migration comes from core (originally 20260513185349)
class RemoveTimestampsFromCoreNodeStates < ActiveRecord::Migration[7.2]
  def change
    remove_column :core_node_states, :created_at, :datetime, if_exists: true
    remove_column :core_node_states, :updated_at, :datetime, if_exists: true
  end
end
