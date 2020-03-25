# This migration comes from wikiplus (originally 20180327103402)
class ChangeWikiplusTranslation < ActiveRecord::Migration
  def change
    rename_column :wikiplus_pages, :name, :name_ru
    add_column :wikiplus_pages, :name_en, :string

    rename_column :wikiplus_pages, :content, :content_ru
    add_column :wikiplus_pages, :content_en, :text
  end
end
