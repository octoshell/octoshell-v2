# This migration comes from sessions (originally 20141013134532)
class CreateSessionsUserSurveys < ActiveRecord::Migration
  def change
    create_table :sessions_user_surveys do |t|
      t.integer :user_id
      t.integer :session_id
      t.integer :survey_id
      t.integer :project_id
      t.string :state

      t.timestamps
      t.index :user_id
      t.index :session_id
      t.index :project_id
      t.index [:session_id, :survey_id]
    end
  end
end
