class Pseudo3FinalChanges < ActiveRecord::Migration
  def change
  	remove_column :pack_accesses,:begin_lic
  	remove_column :pack_accesses,:new_end_lic
  	remove_column :pack_accesses,:ticket_id
  	remove_column :pack_packages,:deleted
  	remove_column :pack_packages,:lock_version
  	add_column :pack_accesses,:begin_lic,:date
  	add_column :pack_accesses,:new_end_lic,:date
  	add_column :pack_versions,:lock_version ,:integer,default: 0,     null: false
  	remove_column :pack_props,:def_date
  	add_column :pack_props,:def_date,:date
  	add_column :pack_versions,:deleted,:date
  end
end
