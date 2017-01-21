class AddActiveToClusterver < ActiveRecord::Migration
  def change
  	add_column :pack_clustervers, :active, :boolean
  end
end
