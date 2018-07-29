# This migration comes from core (originally 20180727081458)
class AddReasonToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :reason, :text
  end
end
