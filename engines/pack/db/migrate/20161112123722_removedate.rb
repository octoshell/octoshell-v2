class Removedate < ActiveRecord::Migration
  def change

    remove_column :pack_packages, :license_date,:datetime 
    add_column :pack_packages, :description, :text
  

  end
end
