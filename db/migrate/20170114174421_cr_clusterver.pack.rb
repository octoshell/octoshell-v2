# This migration comes from pack (originally 20170114174104)
class CrClusterver < ActiveRecord::Migration
   def change
    create_table :pack_clustervers do |t|
      t.belongs_to :core_cluster,index: true
      t.belongs_to :version,index: true
      t.timestamps
    end
  end
end
