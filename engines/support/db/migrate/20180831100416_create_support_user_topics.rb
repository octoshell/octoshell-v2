class CreateSupportUserTopics < ActiveRecord::Migration
  def change
    create_table :support_user_topics do |t|
      t.belongs_to :user
      t.belongs_to :topic
      t.boolean :required, default: false
      t.timestamps null: false
    end
  end
end
