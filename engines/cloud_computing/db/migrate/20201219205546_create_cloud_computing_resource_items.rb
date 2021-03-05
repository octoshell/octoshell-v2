class CreateCloudComputingResourceItems < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_resource_items do |t|
      t.belongs_to :resource
      t.belongs_to :item
      t.string :value
      t.timestamps
    end
  end
end
