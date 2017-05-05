# This migration comes from pack (originally 20170503231639)
class Rename < ActiveRecord::Migration
  def change
  	rename_column :pack_versions,:lock_version,:lock_col
  end
end
