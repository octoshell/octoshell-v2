# This migration comes from authentication (originally 20140312063729)
class SorceryUserActivation < ActiveRecord::Migration
  def change
    add_column :authentication_users, :activation_state, :string, :default => nil
    add_column :authentication_users, :activation_token, :string, :default => nil
    add_column :authentication_users, :activation_token_expires_at, :datetime, :default => nil

    add_index :authentication_users, :activation_token
  end
end
