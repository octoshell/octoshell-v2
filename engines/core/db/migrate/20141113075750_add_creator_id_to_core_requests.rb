class AddCreatorIdToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :creator_id, :integer
    add_index :core_requests, :creator_id
  end
end
