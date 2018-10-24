class CreateHardwareItemsStates < ActiveRecord::Migration
  def change
    create_table :hardware_items_states do |t|
      t.belongs_to :item
      t.belongs_to :state
      t.text :reason_en
      t.text :reason_ru
      t.timestamps null: false
    end
  end
end
