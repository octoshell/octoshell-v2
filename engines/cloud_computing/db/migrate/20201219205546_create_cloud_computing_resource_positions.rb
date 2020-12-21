class CreateCloudComputingResourcePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_resource_positions do |t|
      t.belongs_to :resource
      t.belongs_to :position
      t.decimal :value
      t.timestamps
    end
  end
end
