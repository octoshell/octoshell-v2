class AddCreatedFromAdminToSupportTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :support_tickets, :created_from_admin, :boolean, default: false
  end
end
