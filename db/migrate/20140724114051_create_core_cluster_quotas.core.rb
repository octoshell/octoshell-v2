# This migration comes from core (originally 20140721095932)
class CreateCoreClusterQuotas < ActiveRecord::Migration
  def change
    create_table :core_cluster_quotas do |t|
      t.integer "cluster_id", null: false
      t.string  "name"
      t.integer "value"

      t.index :cluster_id
    end
  end
end
