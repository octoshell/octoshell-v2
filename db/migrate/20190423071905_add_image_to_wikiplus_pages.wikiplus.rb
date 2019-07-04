# This migration comes from wikiplus (originally 20190423071318)
class AddImageToWikiplusPages < ActiveRecord::Migration
  def change
    add_column :wikiplus_pages, :image, :string
  end
end
