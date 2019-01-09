class AddPathToPackClusterver < ActiveRecord::Migration
  def change
    add_column :pack_clustervers, :path, :string
  end
end
