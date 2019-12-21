class AddSortidToWikiplusPages < ActiveRecord::Migration
  def change
    add_column :wikiplus_pages, :sortid, :decimal
  end
end
