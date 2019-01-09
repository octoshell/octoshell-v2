class AddChangedByToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :changed_by_id, :integer
    add_index :core_requests, :changed_by_id
  end
end
