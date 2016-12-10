# This migration comes from pack (originally 20161203091725)
class RenameClusterver < ActiveRecord::Migration
 
  def change
   
    rename_column :pack_clustervers, :versions_id, :version_id
	rename_column :pack_clustervers, :clusters_id, :cluster_id
    
  

  end
end
