# This migration comes from pack (originally 20170114194236)
class AddActiveToClusterver < ActiveRecord::Migration
  def change
  	add_column :pack_clustervers, :active, :boolean
  end
end
