# This migration comes from pack (originally 20170320083545)
class AddLockToAccesses < ActiveRecord::Migration
  def change
  	add_column :pack_accesses,:lock_version,:integer,default: 0,null: false
  end
end
