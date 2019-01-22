# This migration comes from core (originally 20141205152635)
class AddProjectIdToClusterLogs < ActiveRecord::Migration
  def change
    add_column :core_cluster_logs, :project_id, :integer
    add_index :core_cluster_logs, :project_id
  end
end
