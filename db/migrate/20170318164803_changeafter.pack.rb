# This migration comes from pack (originally 20170318164003)
class Changeafter < ActiveRecord::Migration
  def change
  	remove_column :pack_accesses,:begin_lic
  	rename_column :pack_accesses,:user_id,:created_by_key
  	add_column :pack_accesses,:allowed_by_key,:integer
  	add_column :pack_packages,:deleted,:boolean
  end
end
