# This migration comes from pack (originally 20170121173323)
class AddProjectToProp < ActiveRecord::Migration
  def change


  	add_column :pack_props,:project_id,:integer,index: true
   	remove_column :pack_accesses,:project,:integer,index: true
  end
end
