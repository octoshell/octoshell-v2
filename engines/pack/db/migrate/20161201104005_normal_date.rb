class NormalDate < ActiveRecord::Migration
  def change
  	remove_column :pack_versions, :r_up,:datetime 
    add_column  :pack_versions, :r_up,:text 
    remove_column :pack_versions, :r_down,:datetime 
    add_column  :pack_versions, :r_down,:text 
  end
end
