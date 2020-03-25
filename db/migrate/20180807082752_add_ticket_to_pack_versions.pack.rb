# This migration comes from pack (originally 20180807082222)
class AddTicketToPackVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :pack_versions, :ticket_id, :integer
  end
end
