# This migration comes from core (originally 20140722074128)
class AddAccessStateColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_state, :string
  end
end
