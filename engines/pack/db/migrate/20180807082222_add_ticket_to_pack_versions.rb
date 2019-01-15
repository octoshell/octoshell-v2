class AddTicketToPackVersions < ActiveRecord::Migration
  def change
    add_column :pack_versions, :ticket_id, :integer
  end
end
