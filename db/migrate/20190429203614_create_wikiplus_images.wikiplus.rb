# This migration comes from wikiplus (originally 20190429195911)
class CreateWikiplusImages < ActiveRecord::Migration
  def change
    create_table :wikiplus_images do |t|
      t.string :image

      t.timestamps null: false
    end
  end
end
