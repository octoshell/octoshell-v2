# This migration comes from pack (originally 20170204090154)
class RenameType < ActiveRecord::Migration
  def change
  	rename_column :pack_versions,:type,:vers_type
  end
end
