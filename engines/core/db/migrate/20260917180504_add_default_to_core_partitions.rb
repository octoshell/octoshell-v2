class AddDefaultToCorePartitions < ActiveRecord::Migration[8.0]
  def change
    add_column :core_partitions, :default, :boolean, default: false, null: false
  end
end
