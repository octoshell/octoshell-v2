# This migration comes from support (originally 20180831100416)
class CreateSupportUserTopics < ActiveRecord::Migration[4.2]
  def change
    create_table :support_user_topics do |t|
      t.belongs_to :user
      t.belongs_to :topic
      t.boolean :required, default: false
      t.timestamps null: false
    end
  end
end
