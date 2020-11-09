class CreateCloudComputingConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_configurations do |t|
      t.belongs_to :cluster
      t.string :name_ru
      t.string :name_en
      t.text :description_ru
      t.text :description_en
      t.integer :available
      t.integer :position
      t.boolean :new_requests, default: false
      t.timestamps
    end
  end
end
