# This migration comes from api (originally 20190701115811)
class AddTextToApiExport < ActiveRecord::Migration
  def change
    add_column :api_exports, :text, :text
  end
end
