# This migration comes from support (originally 20191004095938)
class AddModelCollectionToSupportField < ActiveRecord::Migration[5.2]
  def change
    add_column :support_fields, :model_collection, :string
  end
end
