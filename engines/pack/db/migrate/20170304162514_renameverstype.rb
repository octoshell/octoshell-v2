class Renameverstype < ActiveRecord::Migration
  def change
  	rename_column(:pack_versions, :vers_type, :state)
  end
end
