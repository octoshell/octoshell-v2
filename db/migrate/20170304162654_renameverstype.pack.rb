# This migration comes from pack (originally 20170304162514)
class Renameverstype < ActiveRecord::Migration
  def change
  	rename_column(:pack_versions, :vers_type, :state)
  end
end
