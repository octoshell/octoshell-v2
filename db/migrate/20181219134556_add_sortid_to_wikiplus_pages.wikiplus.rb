# This migration comes from wikiplus (originally 20181219134543)
class AddSortidToWikiplusPages < ActiveRecord::Migration[4.2]
  def change
    add_column :wikiplus_pages, :sortid, :decimal
  end
end
