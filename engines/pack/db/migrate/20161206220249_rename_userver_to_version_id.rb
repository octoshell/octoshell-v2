class RenameUserverToVersionId < ActiveRecord::Migration
  def change
  	rename_column :pack_uservers, :pack_version_id, :version_id
  end
end
