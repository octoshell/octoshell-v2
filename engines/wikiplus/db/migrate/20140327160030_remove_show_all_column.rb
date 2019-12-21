class RemoveShowAllColumn < ActiveRecord::Migration
  def change
    remove_column :wikiplus_pages, :show_all
  end
end
