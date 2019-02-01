# This migration comes from authentication (originally 20140402033029)
class RenameAuthUsersToUsers < ActiveRecord::Migration
  def change
    rename_table :authentication_users, :users
  end
end
