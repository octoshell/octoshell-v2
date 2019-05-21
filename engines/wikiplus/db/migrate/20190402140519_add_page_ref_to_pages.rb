class AddPageRefToPages < ActiveRecord::Migration
  def change
    add_reference :wikiplus_pages, :mainpage, index: true
  end
end
