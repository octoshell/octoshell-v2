# This migration comes from core (originally 20150114094802)
class CreateCoreEmploymentPositionNames < ActiveRecord::Migration[4.2]
  def change
    create_table :core_employment_position_names do |t|
      t.string :name
      t.text :autocomplete

      t.timestamps
    end
  end
end
