class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer "user_id",     null: false
      t.string  "first_name"
      t.string  "last_name"
      t.string  "middle_name"
      t.text    "about"
    end
  end
end
