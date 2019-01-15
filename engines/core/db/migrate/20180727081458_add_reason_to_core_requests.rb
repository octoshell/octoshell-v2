class AddReasonToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :reason, :text
  end
end
