class CreateSessionsSurveys < ActiveRecord::Migration
  def change
    create_table :sessions_surveys do |t|
      t.integer :session_id
      t.integer :kind_id
      t.string :name
      t.boolean :only_for_project_owners

      t.index :session_id
      t.index :kind_id
    end
  end
end
