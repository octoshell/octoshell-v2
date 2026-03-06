# frozen_string_literal: true

class CreateCoreNodeStates < ActiveRecord::Migration[8.0]
  def change
    create_table :core_node_states do |t|
      t.references :node, null: false, foreign_key: { to_table: :core_nodes }
      t.string :state, null: false
      t.text :reason
      t.datetime :state_time, null: false
      t.timestamps
    end

    add_index :core_node_states, :state_time
    add_index :core_node_states, :id
  end
end
