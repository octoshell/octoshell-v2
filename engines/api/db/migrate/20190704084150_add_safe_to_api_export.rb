class AddSafeToApiExport < ActiveRecord::Migration
  def change
    add_column :api_exports, :safe, :boolean, default: true
  end
end
