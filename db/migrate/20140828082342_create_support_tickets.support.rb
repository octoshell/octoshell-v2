# This migration comes from support (originally 20140827134108)
class CreateSupportTickets < ActiveRecord::Migration
  def change
    create_table :support_tickets do |t|
      t.integer :topic_id
      t.integer :project_id
      t.integer :cluster_id
      t.integer :surety_id
      t.integer :reporter_id

      t.string :subject
      t.text :message
      t.string :state
      t.string :url
      t.string :attachment

      t.timestamps

      t.index :topic_id
      t.index :reporter_id
      t.index :project_id
      t.index :cluster_id
      t.index :state
    end

    create_table :support_tickets_tags do |t|
      t.integer :ticket_id
      t.integer :tag_id

      t.index :ticket_id
      t.index :tag_id
    end

    create_table :support_tickets_subscribers do |t|
      t.integer :ticket_id
      t.integer :user_id

      t.index :ticket_id
      t.index :user_id
      t.index [:ticket_id, :user_id], unique: true
    end
  end
end
