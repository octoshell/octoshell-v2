class CreateCloudComputingRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_requests do |t|
      t.text :comment
      t.text :admin_comment
      t.date :finish_date
      t.belongs_to :created_by
      t.belongs_to :access
      t.references :for, polymorphic: true
      t.string :status
      t.timestamps
    end
  end
end
