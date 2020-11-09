class CreateCloudComputingRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_requests do |t|
      t.text :comment
      t.belongs_to :configuration
      t.date :finish_date
      t.belongs_to :created_by
      t.references :for, polymorphic: true
      t.integer :amount
      t.string :status
      t.timestamps
    end
  end
end
