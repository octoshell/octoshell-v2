class AddNoteToCoreResourceControls < ActiveRecord::Migration[7.2]
  def change
    add_column :core_resource_controls, :note, :string
  end
end
