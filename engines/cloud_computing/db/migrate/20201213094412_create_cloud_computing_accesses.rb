class CreateCloudComputingAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_accesses do |t|
      t.date :finish_date
      t.belongs_to :user
      t.belongs_to :allowed_by
      t.belongs_to :request
      t.references :for, polymorphic: true
      t.string :state
      t.timestamps

      t.timestamps
    end
  end
end
