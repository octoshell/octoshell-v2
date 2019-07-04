class RenameApiAbilitiesToAccessKeys < ActiveRecord::Migration
  def change
    rename_table :api_abilities, :api_access_keys
    rename_column :api_abilities_exports, :ability_id, :access_key_id
  end
end
