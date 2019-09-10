# This migration comes from pack (originally 20180816122617)
class AddValueIdToVersionOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :pack_version_options, :category_value_id, :integer
  end
end
