class CreateCoreEmploymentPositionNames < ActiveRecord::Migration
  def change
    create_table :core_employment_position_names do |t|
      t.string :name
      t.text :autocomplete

      t.timestamps
    end
  end
end
