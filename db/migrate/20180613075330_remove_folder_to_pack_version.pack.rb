# This migration comes from pack (originally 20180613075111)
class RemoveFolderToPackVersion < ActiveRecord::Migration
  def change
    remove_column :pack_versions, :folder, :string
  end
end
