class CreateFaceMenuItemPrefs < ActiveRecord::Migration[5.2]
  def change
    create_table :face_menu_item_prefs do |t|
      t.integer :position
      t.string :menu
      t.index :position
      t.text :url
      t.belongs_to :user_id
      t.boolean :admin, default: false
      t.timestamps
    end
  end
end
