class RenameAbilitiesToPermissions < ActiveRecord::Migration[5.2]
  def change
    rename_table :abilities, :permissions
  end
end
