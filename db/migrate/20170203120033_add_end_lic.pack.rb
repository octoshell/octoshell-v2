# This migration comes from pack (originally 20170201074452)
class AddEndLic < ActiveRecord::Migration
  def change
  	remove_column :pack_versions,:r_up
  	remove_column :pack_versions,:r_down
  	remove_column :pack_accesses,:admin_answer
  	remove_column :pack_accesses,:end_date
  	remove_column :pack_accesses,:request_text
  	remove_column :pack_packages,:folder
  	add_column :pack_versions,:end_lic,:string
  	add_column :pack_accesses,:new_end_lic,:string
  	add_column :pack_versions,:type,:integer,default: 0
  	add_column :pack_accesses,:ticket_id,:integer,index: true
  	add_column :pack_versions,:folder,:integer,index: true
  end
end
