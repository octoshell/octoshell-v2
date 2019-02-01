# This migration comes from sessions (originally 20141013141731)
class CreateSessionsStats < ActiveRecord::Migration
  def change
    create_table :sessions_stats do |t|
      t.integer :session_id
      t.integer :survey_field_id
      t.string :group_by, default: "count"
      t.integer :weight, default: 0
      t.integer :organization_id
      t.text :cache

      t.index :session_id
      t.index [:session_id, :survey_field_id]
      t.index [:session_id, :organization_id]
    end
  end
end
