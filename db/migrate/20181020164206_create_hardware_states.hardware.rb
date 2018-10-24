# This migration comes from hardware (originally 20181017142216)
class CreateHardwareStates < ActiveRecord::Migration
  def change
    create_table :hardware_states do |t|
      t.string "name_ru"
      t.string "name_en"
      t.text "description_ru"
      t.text "description_en"
      t.integer :lock_version
      t.belongs_to :kind
      t.timestamps null: false
    end
  end
end
