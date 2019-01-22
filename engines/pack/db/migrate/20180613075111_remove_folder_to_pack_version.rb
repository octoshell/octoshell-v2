class RemoveFolderToPackVersion < ActiveRecord::Migration
  def change
    remove_column :pack_versions, :folder, :string
  end
end
