class CreateFaceMenuItemPrefs < ActiveRecord::Migration[5.2]
  def change
    create_table :face_menu_item_prefs do |t|
      t.integer :position
      t.string :menu
      t.index :position
      t.string :key
      t.index :key
      t.belongs_to :user
      t.boolean :admin, default: false
      t.timestamps
    end
  end
end
