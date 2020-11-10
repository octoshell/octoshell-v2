# This migration comes from pack (originally 20201101121723)
class AddTicketCreatedToPackVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :pack_versions, :ticket_created, :boolean, default: false
  end
end
