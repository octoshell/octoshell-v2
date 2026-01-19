class CreateCommentsComments < ActiveRecord::Migration
  def change
    create_table :comments_comments do |t|
      t.text :text
      t.belongs_to :attachable, { index: true, null: false, polymorphic: true }
      t.belongs_to :user, { index: true, null: false }
      t.belongs_to :context, { index: true }
      t.timestamps null: false
    end
  end
end
