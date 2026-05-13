class AddSnapshotIdToCoreNodeStates < ActiveRecord::Migration[7.2]
  def change
    add_reference :core_node_states, :snapshot, foreign_key: { to_table: :core_snapshots }, index: true, null: true
  end
end
