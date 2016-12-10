# This migration comes from pack (originally 20161124110727)
class AddClusterActiveDefault < ActiveRecord::Migration
  def change
  	remove_column :pack_clustervers, :active, :boolean
    add_column :pack_clustervers, :active, :boolean,default: true
  end
end
