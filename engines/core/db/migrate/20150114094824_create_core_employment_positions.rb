class CreateCoreEmploymentPositions < ActiveRecord::Migration
  def change
    create_table :core_employment_positions do |t|
      t.integer :employment_id
      t.string :name
      t.string :value

      t.timestamps

      t.index :employment_id
    end
  end
end
