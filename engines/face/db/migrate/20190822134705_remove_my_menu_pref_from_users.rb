class RemoveMyMenuPrefFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :my_menu_pref, :boolean
  end
end
