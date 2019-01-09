# This migration comes from core (originally 20141120075403)
class AddAwalibleForWorkToCoreClusters < ActiveRecord::Migration
  def change
    add_column :core_clusters, :available_for_work, :boolean, default: true
  end
end
