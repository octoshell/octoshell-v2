# This migration comes from core (originally 20190125111147)
class CreateCorePartition < ActiveRecord::Migration
  def change
    create_table :core_partitions do |t|
      t.string :name
      t.integer :cluster_id, index: true
      t.string :resources
    end
  end
end
