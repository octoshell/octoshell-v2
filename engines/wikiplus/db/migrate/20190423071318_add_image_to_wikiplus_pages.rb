class AddImageToWikiplusPages < ActiveRecord::Migration
  def change
    add_column :wikiplus_pages, :image, :string
  end
end
