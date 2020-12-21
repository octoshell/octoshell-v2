class CreateCloudComputingConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_conditions do |t|
      t.references :from, polymorphic: true
      t.references :to, polymorphic: true
      t.integer :min, default: 0
      t.integer :max
      t.timestamps
    end
  end
end
