class AddModelCollectionToSupportField < ActiveRecord::Migration[5.2]
  def change
    add_column :support_fields, :model_collection, :string
  end
end
