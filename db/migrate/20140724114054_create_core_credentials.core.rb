# This migration comes from core (originally 20140721100351)
class CreateCoreCredentials < ActiveRecord::Migration
  def change
    create_table :core_credentials do |t|
      t.integer "user_id",    null: false
      t.string  "state"
      t.string  "name",       null: false
      t.text    "public_key", null: false

      t.index :user_id
    end
  end
end
