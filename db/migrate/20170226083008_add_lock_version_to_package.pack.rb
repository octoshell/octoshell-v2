# This migration comes from pack (originally 20170226082639)
class AddLockVersionToPackage < ActiveRecord::Migration
  def change
  	add_column :pack_packages,:lock_version,:integer,default: 0, null: false
  end
end
