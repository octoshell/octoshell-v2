class AddMyMenuPrefToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :my_menu_pref, :boolean, default: false
  end
end
