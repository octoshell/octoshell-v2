class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.belongs_to :owner, polymorphic: true
      t.string :name_ru
      t.string :name_en
      t.text :value_ru
      t.text :value_en
      t.integer :category_value_id
      t.integer :options_category_id

      t.timestamps null: false
    end
  end
end
