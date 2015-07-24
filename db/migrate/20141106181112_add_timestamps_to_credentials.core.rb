# This migration comes from core (originally 20141106180859)
class AddTimestampsToCredentials < ActiveRecord::Migration
  def change
    add_column :core_credentials, :created_at, :datetime
    add_column :core_credentials, :updated_at, :datetime
  end
end
