class CreateFaceUsersMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :face_users_menus do |t|
      t.string :menu
      t.belongs_to :user
      t.index %i[user_id menu], unique: true
      t.timestamps
    end
  end
end
