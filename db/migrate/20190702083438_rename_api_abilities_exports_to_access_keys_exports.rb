class RenameApiAbilitiesExportsToAccessKeysExports < ActiveRecord::Migration[4.2]
  def change
    rename_table :api_abilities_exports, :api_access_keys_exports
  end
end
