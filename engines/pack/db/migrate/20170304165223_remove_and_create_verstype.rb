class RemoveAndCreateVerstype < ActiveRecord::Migration
  def change
  	remove_column :pack_versions, :state, :string
  	add_column :pack_versions, :state, :string 
  end
end
