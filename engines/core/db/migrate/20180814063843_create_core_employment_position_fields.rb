class CreateCoreEmploymentPositionFields < ActiveRecord::Migration
  def change
    create_table :core_employment_position_fields do |t|
      t.integer :employment_position_name_id
      t.string :name_ru
      t.string :name_en
      t.timestamps null: false
    end
  end
end
