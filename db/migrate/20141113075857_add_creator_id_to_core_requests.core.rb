# This migration comes from core (originally 20141113075750)
class AddCreatorIdToCoreRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :core_requests, :creator_id, :integer
    add_index :core_requests, :creator_id
  end
end
