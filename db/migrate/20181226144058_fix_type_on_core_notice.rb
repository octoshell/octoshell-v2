class FixTypeOnCoreNotice < ActiveRecord::Migration
  def change
    rename_column :core_notices, :type, :category
  end
end
