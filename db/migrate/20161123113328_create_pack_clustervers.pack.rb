# This migration comes from pack (originally 20161123112205)
class CreatePackClustervers < ActiveRecord::Migration
  def change
    create_table :pack_clustervers do |t|
    	t.belongs_to :versions,index: true
    	t.belongs_to :clusters,index: true
    	t.timestamps
    end
  end
end
