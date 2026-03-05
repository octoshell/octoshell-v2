# frozen_string_literal: true

# This migration comes from core (originally 20260305120000)
class CreateCoreNodes < ActiveRecord::Migration[8.0]
  def change
    create_table :core_nodes do |t|
      t.string :name, null: false
      t.references :cluster, null: false, foreign_key: { to_table: :core_clusters }
      t.timestamps
    end

    add_index :core_nodes, %i[cluster_id name], unique: true
  end
end
