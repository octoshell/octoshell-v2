class AddTypeToCoreNotice < ActiveRecord::Migration
  def change
    add_column :core_notices, :type, :integer
  end
end
