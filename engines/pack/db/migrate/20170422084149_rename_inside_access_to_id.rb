class RenameInsideAccessToId < ActiveRecord::Migration
  def change
  	
  	rename_column :pack_accesses,:created_by_key,:created_by_id
  	rename_column :pack_accesses,:allowed_by_key,:allowed_by_id
  end
end
