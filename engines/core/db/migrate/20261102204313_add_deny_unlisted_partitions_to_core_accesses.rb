class AddDenyUnlistedPartitionsToCoreAccesses < ActiveRecord::Migration[8.0]
  def change
    add_column :core_accesses, :deny_unlisted_partitions, :boolean, default: false, null: false
  end
end
