class RemoveClusterver < ActiveRecord::Migration
  def change
  	drop_table :pack_clustervers
  end
end
