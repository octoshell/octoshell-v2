# This migration comes from pack (originally 20180816122617)
class AddValueIdToVersionOptions < ActiveRecord::Migration
  def change
    add_column :pack_version_options, :value_id, :integer
  end
end
