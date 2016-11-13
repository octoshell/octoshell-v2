# This migration comes from pack (originally 20161113102220)
class AddCascadeDeletion < ActiveRecord::Migration
  def change
  	  rename_column :pack_versions, :pack_package_id, :package_id
  end
end
