# This migration comes from hardware (originally 20181017141714)
class CreateHardwareKinds < ActiveRecord::Migration[4.2]
  def change
    create_table :hardware_kinds do |t|
      t.string "name_ru"
      t.string "name_en"
      t.text "description_ru"
      t.text "description_en"

      t.timestamps null: false
    end
  end
end
