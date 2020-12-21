class CreateCloudComputingItems < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_items do |t|
      t.belongs_to :item_kind
      t.string :name_ru
      t.string :name_en
      t.text :description_ru
      t.text :description_en
      t.integer :identity
      t.boolean :new_requests, default: false
      t.timestamps
    end
  end
end
