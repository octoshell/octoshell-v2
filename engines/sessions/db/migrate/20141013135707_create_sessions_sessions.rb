class CreateSessionsSessions < ActiveRecord::Migration
  def change
    create_table :sessions_sessions do |t|
      t.string :state
      t.text :description
      t.text :motivation
      t.datetime :started_at
      t.datetime :ended_at
      t.datetime :receiving_to
    end
  end
end
