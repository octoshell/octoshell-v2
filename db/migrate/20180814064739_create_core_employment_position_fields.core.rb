# This migration comes from core (originally 20180814063843)
class CreateCoreEmploymentPositionFields < ActiveRecord::Migration[4.2]
  def change
    create_table :core_employment_position_fields do |t|
      t.integer :employment_position_name_id
      t.string :name_ru
      t.string :name_en
      t.timestamps null: false
    end
  end
end
