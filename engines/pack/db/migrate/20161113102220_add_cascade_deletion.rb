class AddCascadeDeletion < ActiveRecord::Migration
  def change
  	  rename_column :pack_versions, :pack_package_id, :package_id
  end
end
