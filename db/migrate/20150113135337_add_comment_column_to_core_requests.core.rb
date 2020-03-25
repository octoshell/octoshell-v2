# This migration comes from core (originally 20150113135218)
class AddCommentColumnToCoreRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :core_requests, :comment, :text
  end
end
