# This migration comes from api (originally 20190701115811)
class AddTextToApiExport < ActiveRecord::Migration[4.2]
  def change
    add_column :api_exports, :text, :text
  end
end
