class RenameType < ActiveRecord::Migration
  def change
  	rename_column :pack_versions,:type,:vers_type
  end
end
