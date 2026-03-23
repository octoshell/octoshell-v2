# This migration comes from core (originally 20260323141449)
class AddResourceControlWeightToCorePartitions < ActiveRecord::Migration[7.2]
  def change
    add_column :core_partitions, :resource_control_weight, :integer
  end
end
