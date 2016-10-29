class CreateSessionsReportReplies < ActiveRecord::Migration
  def change
    create_table :sessions_report_replies do |t|
      t.integer :report_id
      t.integer :user_id
      t.text :message
      t.timestamps

      t.index :report_id
    end
  end
end
