# This migration comes from pack (originally 20170114172640)
class RemoveClusterver < ActiveRecord::Migration
  def change
  	drop_table :pack_clustervers
  end
end
