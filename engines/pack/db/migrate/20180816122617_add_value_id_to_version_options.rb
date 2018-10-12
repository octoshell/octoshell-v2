class AddValueIdToVersionOptions < ActiveRecord::Migration
  def change
    add_column :pack_version_options, :category_value_id, :integer
  end
end
