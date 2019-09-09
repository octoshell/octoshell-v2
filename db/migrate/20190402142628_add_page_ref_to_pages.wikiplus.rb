# This migration comes from wikiplus (originally 20190402140519)
class AddPageRefToPages < ActiveRecord::Migration[4.2]
  def change
    add_reference :wikiplus_pages, :mainpage, index: true
  end
end
