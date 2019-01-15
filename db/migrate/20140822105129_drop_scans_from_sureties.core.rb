# This migration comes from core (originally 20140822104339)
class DropScansFromSureties < ActiveRecord::Migration
  def change
    remove_column :core_sureties, :scan
  end
end
