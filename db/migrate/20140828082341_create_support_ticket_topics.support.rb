# This migration comes from support (originally 20140827082329)
class CreateSupportTicketTopics < ActiveRecord::Migration
  def change
    create_table :support_topics do |t|
      t.string  :name
      t.integer :parent_id

      t.timestamps
    end

    create_table :support_topics_tags do |t|
      t.integer :topic_id
      t.integer :tag_id
    end

    create_table :support_topics_fields do |t|
      t.integer :topic_id
      t.integer :field_id
    end
  end
end
