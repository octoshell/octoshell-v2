# This migration comes from wiki (originally 20140327160030)
class RemoveShowAllColumn < ActiveRecord::Migration
  def change
    remove_column :wiki_pages, :show_all
  end
end
