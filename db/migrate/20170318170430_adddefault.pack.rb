# This migration comes from pack (originally 20170318170141)
class Adddefault < ActiveRecord::Migration
  def change
  	change_column :pack_packages, :deleted, :boolean, :default => false
  	change_column :pack_versions, :deleted, :boolean, :default => false

  end
end
