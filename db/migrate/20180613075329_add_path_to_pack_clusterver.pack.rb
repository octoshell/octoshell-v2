# This migration comes from pack (originally 20180613074716)
class AddPathToPackClusterver < ActiveRecord::Migration
  def change
    add_column :pack_clustervers, :path, :string
  end
end
