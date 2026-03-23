class AddResourceControlWeightToCorePartitions < ActiveRecord::Migration[7.2]
  def change
    add_column :core_partitions, :resource_control_weight, :integer
  end
end
