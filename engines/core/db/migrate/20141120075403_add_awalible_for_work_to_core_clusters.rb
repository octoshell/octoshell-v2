class AddAwalibleForWorkToCoreClusters < ActiveRecord::Migration
  def change
    add_column :core_clusters, :available_for_work, :boolean, default: true
  end
end
