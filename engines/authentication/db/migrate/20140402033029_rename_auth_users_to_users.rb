class RenameAuthUsersToUsers < ActiveRecord::Migration
  def change
    rename_table :authentication_users, :users
  end
end
