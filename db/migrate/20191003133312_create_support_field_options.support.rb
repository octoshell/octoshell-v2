# This migration comes from support (originally 20191003132237)
class CreateSupportFieldOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :support_field_options do |t|
      t.belongs_to :field
      t.text :name_ru
      t.text :name_en
      t.timestamps
    end
  end
end
