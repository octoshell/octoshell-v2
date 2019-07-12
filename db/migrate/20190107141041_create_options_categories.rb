class CreateOptionsCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :options_categories do |t|
      t.string :name_ru
      t.string :name_en
      t.timestamps null: false
    end
  end
end
