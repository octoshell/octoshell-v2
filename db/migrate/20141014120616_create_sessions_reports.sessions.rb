# This migration comes from sessions (originally 20141013135123)
class CreateSessionsReports < ActiveRecord::Migration
  def change
    create_table :sessions_reports do |t|
      t.integer :session_id
      t.integer :project_id
      t.integer :author_id
      t.integer :expert_id
      t.string :state
      t.string :materials
      t.string :materials_file_name
      t.string :materials_content_type
      t.integer :materials_file_size
      t.datetime :materials_updated_at
      t.integer :illustration_points
      t.integer :summary_points
      t.integer :statement_points

      t.timestamps

      t.index :session_id
      t.index :author_id
      t.index :expert_id
      t.index :project_id
    end
  end
end
