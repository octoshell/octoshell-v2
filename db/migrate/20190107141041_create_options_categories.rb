class CreateOptionsCategories < ActiveRecord::Migration
  def change
    create_table :options_categories do |t|
      t.string :name_ru
      t.string :name_en
      t.timestamps null: false
    end
  end
end
