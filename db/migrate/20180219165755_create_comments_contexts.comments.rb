# This migration comes from comments (originally 20171215093013)
class CreateCommentsContexts < ActiveRecord::Migration
  def change
    create_table :comments_contexts do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
