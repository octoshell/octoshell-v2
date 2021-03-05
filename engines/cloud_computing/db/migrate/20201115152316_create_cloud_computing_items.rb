class CreateCloudComputingItems < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_items do |t|
      t.belongs_to :template
      t.belongs_to :item
      t.references :holder, polymorphic: true
      t.timestamps
    end
  end
end
