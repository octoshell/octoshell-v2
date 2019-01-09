# This migration comes from authentication (originally 20140312063730)
class SorceryRememberMe < ActiveRecord::Migration
  def change
    add_column :authentication_users, :remember_me_token, :string, :default => nil
    add_column :authentication_users, :remember_me_token_expires_at, :datetime, :default => nil

    add_index :authentication_users, :remember_me_token
  end
end
