class FixTypeOnCoreNotice < ActiveRecord::Migration[4.2]
  def change
    rename_column :core_notices, :type, :category
  end
end
