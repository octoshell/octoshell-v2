# This migration comes from support (originally 20140903090001)
class AddResponsibleAdminToSupportTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :support_tickets, :responsible_id, :integer
    add_index :support_tickets, :responsible_id
  end
end
