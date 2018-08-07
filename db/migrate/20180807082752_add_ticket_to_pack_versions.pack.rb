# This migration comes from pack (originally 20180807082222)
class AddTicketToPackVersions < ActiveRecord::Migration
  def change
    add_column :pack_versions, :ticket_id, :integer
  end
end
