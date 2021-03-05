class CreateCloudComputingConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_conditions do |t|
      t.references :from, polymorphic: true
      t.references :to, polymorphic: true
      t.string :from_multiplicity
      t.string :to_multiplicity
      t.timestamps
    end
  end
end
