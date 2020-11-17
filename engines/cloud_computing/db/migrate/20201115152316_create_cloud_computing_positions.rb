class CreateCloudComputingPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_positions do |t|
      t.belongs_to :item
      t.references :holder, polymorphic: true
      t.integer :amount, polymorphic: true
      t.timestamps
    end
  end
end
