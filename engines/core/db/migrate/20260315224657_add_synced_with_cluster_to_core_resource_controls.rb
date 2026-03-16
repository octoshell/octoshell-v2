class AddSyncedWithClusterToCoreResourceControls < ActiveRecord::Migration[7.2]
  def change
    add_column :core_resource_controls, :synced_with_cluster, :boolean
  end
end
