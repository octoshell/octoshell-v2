class AddLockVersionToPackage < ActiveRecord::Migration
  def change
  	add_column :pack_packages,:lock_version,:integer,default: 0, null: false
  end
end
