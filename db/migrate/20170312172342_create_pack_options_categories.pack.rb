# This migration comes from pack (originally 20170312171225)
class CreatePackOptionsCategories < ActiveRecord::Migration
  def change
    create_table :pack_options_categories do |t|

      t.string :category


      t.timestamps null: false
    end
  end
end
