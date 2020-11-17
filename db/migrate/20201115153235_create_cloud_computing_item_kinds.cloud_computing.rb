# This migration comes from cloud_computing (originally 20201110154436)
class CreateCloudComputingItemKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_item_kinds do |t|
      t.string :name_ru
      t.string :name_en
      t.text :description_ru
      t.text :description_en
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0
      t.timestamps
    end
  end
end
