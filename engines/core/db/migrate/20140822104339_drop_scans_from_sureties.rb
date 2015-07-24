class DropScansFromSureties < ActiveRecord::Migration
  def change
    remove_column :core_sureties, :scan
  end
end
