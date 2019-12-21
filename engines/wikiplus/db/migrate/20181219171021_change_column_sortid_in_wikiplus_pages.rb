class ChangeColumnSortidInWikiplusPages < ActiveRecord::Migration
  def change
    change_column :wikiplus_pages, :sortid, :decimal, precision: 5, scale: 0
  end
end
