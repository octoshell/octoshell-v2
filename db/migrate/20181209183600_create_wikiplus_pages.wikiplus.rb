# This migration comes from wikiplus (originally 20140327103402)
class CreateWikiplusPages < ActiveRecord::Migration
  def change
    create_table :wikiplus_pages do |t|
      t.string :name
      t.text :content
      t.string :url
      t.boolean :show_all, default: true
      t.timestamps

      t.index :url, unique: true
    end
  end
end
