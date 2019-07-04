# This migration comes from wikiplus (originally 20181219171021)
class ChangeColumnSortidInWikiplusPages < ActiveRecord::Migration
  def change
    change_column :wikiplus_pages, :sortid, :decimal, precision: 5, scale: 0
  end
end
