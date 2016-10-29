# This migration comes from sessions (originally 20141029133251)
class CreateSessionsProjectsInSessions < ActiveRecord::Migration
  def change
    create_table :sessions_projects_in_sessions do |t|
      t.integer :session_id
      t.integer :project_id

      t.index :session_id
      t.index :project_id
      t.index [:session_id, :project_id], unique: true, name: :i_on_project_and_sessions_ids
    end
  end
end
