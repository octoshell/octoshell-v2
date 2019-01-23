# This migration comes from hardware (originally 20181020153214)
class CreateHardwareStatesLinks < ActiveRecord::Migration
  def change
    create_table :hardware_states_links do |t|
      t.belongs_to :from
      t.belongs_to :to
      t.timestamps null: false
    end
  end
end
