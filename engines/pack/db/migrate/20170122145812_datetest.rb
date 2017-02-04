class Datetest < ActiveRecord::Migration
  def change
  	remove_column :pack_versions,:r_up
  	add_column :pack_versions, :r_up, :date
  end
end
