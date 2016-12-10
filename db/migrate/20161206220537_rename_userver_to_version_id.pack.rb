# This migration comes from pack (originally 20161206220249)
class RenameUserverToVersionId < ActiveRecord::Migration
  def change
  	rename_column :pack_uservers, :pack_version_id, :version_id
  end
end
