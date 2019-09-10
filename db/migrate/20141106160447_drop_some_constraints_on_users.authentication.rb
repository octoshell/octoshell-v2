# This migration comes from authentication (originally 20141106160321)
class DropSomeConstraintsOnUsers < ActiveRecord::Migration[4.2]
  def change
    change_column_null :users, :salt, true
    change_column_null :users, :crypted_password, true
  end
end
