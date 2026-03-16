# This migration comes from core (originally 20260315173301)
class AddNoteToCoreResourceControls < ActiveRecord::Migration[7.2]
  def change
    add_column :core_resource_controls, :note, :string
  end
end
