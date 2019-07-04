# This migration comes from api (originally 20190704084150)
class AddSafeToApiExport < ActiveRecord::Migration
  def change
    add_column :api_exports, :safe, :boolean, default: true
  end
end
