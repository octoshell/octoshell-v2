# This migration comes from wikiplus (originally 20260602145100)
class CreateWikiplusPageGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :wikiplus_page_groups do |t|
      t.belongs_to :page, null: false, index: true
      t.belongs_to :group, null: false, index: true

      t.timestamps null: false
    end

    add_index :wikiplus_page_groups, %i[page_id group_id], unique: true
  end
end
