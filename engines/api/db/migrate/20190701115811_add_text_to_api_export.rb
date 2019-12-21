class AddTextToApiExport < ActiveRecord::Migration
  def change
    add_column :api_exports, :text, :text
  end
end
