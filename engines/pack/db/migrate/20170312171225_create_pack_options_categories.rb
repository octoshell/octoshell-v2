class CreatePackOptionsCategories < ActiveRecord::Migration
  def change
    create_table :pack_options_categories do |t|

      t.string :category


      t.timestamps null: false
    end
  end
end
