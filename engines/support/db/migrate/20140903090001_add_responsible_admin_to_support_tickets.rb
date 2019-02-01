class AddResponsibleAdminToSupportTickets < ActiveRecord::Migration
  def change
    add_column :support_tickets, :responsible_id, :integer
    add_index :support_tickets, :responsible_id
  end
end
