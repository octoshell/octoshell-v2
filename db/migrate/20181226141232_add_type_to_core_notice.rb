class AddTypeToCoreNotice < ActiveRecord::Migration[4.2]
  def change
    add_column :core_notices, :type, :integer
  end
end
