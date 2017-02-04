# This migration comes from pack (originally 20170121123037)
class ChangeCostAndAddProjectsToPref < ActiveRecord::Migration
  def change
  	remove_column :pack_packages,:cost
  	add_column :pack_versions,:cost,:integer
   	add_column :pack_accesses,:project,:integer,index: true

  end
end
