class DropSomeConstraintsOnUsers < ActiveRecord::Migration
  def change
    change_column_null :users, :salt, true
    change_column_null :users, :crypted_password, true
  end
end
