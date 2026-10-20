class AddPortToCoreClusters < ActiveRecord::Migration[8.0]
  def change
    add_column :core_clusters, :port, :integer, default: 22, null: false
  end
end
