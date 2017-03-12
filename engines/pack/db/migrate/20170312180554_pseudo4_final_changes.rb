class Pseudo4FinalChanges < ActiveRecord::Migration
  def change
  	remove_column :pack_versions,:deleted
  	add_column :pack_versions,:deleted,:boolean
  end
end
