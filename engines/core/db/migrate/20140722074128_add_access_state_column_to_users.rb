class AddAccessStateColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_state, :string
  end
end
