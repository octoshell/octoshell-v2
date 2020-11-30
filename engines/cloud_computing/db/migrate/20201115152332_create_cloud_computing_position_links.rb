class CreateCloudComputingPositionLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_position_links do |t|
      t.belongs_to :from
      t.belongs_to :to
      t.integer :amount
      t.timestamps
    end
  end
end
