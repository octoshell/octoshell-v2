class CreateHardwareItems < ActiveRecord::Migration
  def change
    create_table :hardware_items do |t|
      t.string :name_ru
      t.string :name_en
      t.text :description_ru
      t.text :description_en
      t.integer :lock_version
      t.belongs_to :kind
      t.timestamps null: false
    end
  end
end
