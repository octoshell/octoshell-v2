# This migration comes from authentication (originally 20141106154048)
class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime
  end
end
