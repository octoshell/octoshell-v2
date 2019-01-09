class CreatePackCategoryValues < ActiveRecord::Migration
  def change
    create_table :pack_category_values do |t|
      t.integer :options_category_id, index: true
      t.string :value_ru
      t.string :value_en
      t.timestamps null: false
    end
  end
end
