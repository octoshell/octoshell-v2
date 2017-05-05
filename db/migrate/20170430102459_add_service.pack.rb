# This migration comes from pack (originally 20170430102009)
class AddService < ActiveRecord::Migration
  def change
  	add_column :pack_versions,:service,:boolean,default: false,null: false
  end
end
