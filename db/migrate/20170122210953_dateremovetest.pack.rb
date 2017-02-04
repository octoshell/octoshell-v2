# This migration comes from pack (originally 20170122210800)


class Dateremovetest < ActiveRecord::Migration
  def change
  	remove_column :pack_versions,:r_up
  	add_column :pack_versions, :r_up, :text
  
  end
end
