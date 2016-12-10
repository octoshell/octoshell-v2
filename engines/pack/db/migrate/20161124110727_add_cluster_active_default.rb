class AddClusterActiveDefault < ActiveRecord::Migration
  def change
  	remove_column :pack_clustervers, :active, :boolean
    add_column :pack_clustervers, :active, :boolean,default: true
  end
end
