class RemoveShowAllColumn < ActiveRecord::Migration
  def change
    remove_column :wiki_pages, :show_all
  end
end
