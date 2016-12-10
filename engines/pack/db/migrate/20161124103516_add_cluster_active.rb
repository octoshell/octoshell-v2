class AddClusterActive < ActiveRecord::Migration
  def change
  	remove_column :pack_versions, :active,:boolean 
    add_column :pack_clustervers, :active, :boolean
  end
end
