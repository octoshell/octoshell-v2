# This migration comes from pack (originally 20161112123722)
class Removedate < ActiveRecord::Migration
  def change

    remove_column :pack_packages, :license_date,:datetime 
    add_column :pack_packages, :description, :text
  

  end
end
