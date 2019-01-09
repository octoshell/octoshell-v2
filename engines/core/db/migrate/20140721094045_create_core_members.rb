class CreateCoreMembers < ActiveRecord::Migration
  def change
    create_table :core_members do |t|
      t.integer "user_id",                              null: false
      t.integer "project_id",                           null: false
      t.boolean "owner",                default: false
      t.string  "login"
      t.string  "project_access_state"
      t.timestamps

      t.index ["owner", "user_id", "project_id"]
      t.index ["project_id"]
      t.index ["user_id", "project_id"], unique: true
      t.index ["user_id"]
      t.index ["project_access_state"]
    end
  end
end
