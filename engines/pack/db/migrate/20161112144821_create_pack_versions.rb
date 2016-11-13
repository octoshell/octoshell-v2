class CreatePackVersions < ActiveRecord::Migration
  def change
    create_table :pack_versions do |t|
      t.string :name
      t.text :description
      t.datetime :r_up
      t.datetime :r_down
      t.boolean :active
      t.belongs_to :pack_package, index: true

      t.timestamps 
    end
  end
end
