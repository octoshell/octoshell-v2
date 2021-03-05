class CreateCloudComputingResources < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_resources do |t|
      t.belongs_to :resource_kind
      t.belongs_to :template
      t.string :value
      t.boolean :editable, default: false
      t.decimal :min
      t.decimal :max
      t.timestamps
    end
  end
end
