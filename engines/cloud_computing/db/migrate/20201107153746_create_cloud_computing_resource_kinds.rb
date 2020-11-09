class CreateCloudComputingResourceKinds < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_resource_kinds do |t|
      t.string :name_ru
      t.string :name_en
      t.text :description_en
      t.text :description_ru
      t.string :measurement_ru
      t.string :measurement_en
      t.timestamps
    end
  end
end
