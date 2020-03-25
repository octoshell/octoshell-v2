# This migration comes from pack (originally 20180816122123)
class CreatePackCategoryValues < ActiveRecord::Migration[4.2]
  def change
    create_table :pack_category_values do |t|
      t.integer :options_category_id, index: true
      t.string :value_ru
      t.string :value_en
      t.timestamps null: false
    end
  end
end
