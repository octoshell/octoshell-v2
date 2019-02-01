class AddCommentColumnToCoreRequests < ActiveRecord::Migration
  def change
    add_column :core_requests, :comment, :text
  end
end
