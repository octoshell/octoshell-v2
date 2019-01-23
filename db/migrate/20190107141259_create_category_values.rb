class CreateCategoryValues < ActiveRecord::Migration
  def change
    create_table :category_values do |t|
      t.integer :options_category_id, index: true
      t.string :value_ru
      t.string :value_en
      t.timestamps null: false
    end
  end
end
