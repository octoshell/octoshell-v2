# This migration comes from pack (originally 20161115081115)
class ShowDeleted < ActiveRecord::Migration
  def change
  	add_column :pack_packages, :deleted, :boolean,default: false
  end
end
