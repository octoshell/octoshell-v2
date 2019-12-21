class CreateWikiplusImages < ActiveRecord::Migration
  def change
    create_table :wikiplus_images do |t|
      t.string :image

      t.timestamps null: false
    end
  end
end
