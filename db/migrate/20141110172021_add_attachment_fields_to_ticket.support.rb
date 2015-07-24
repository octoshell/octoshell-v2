# This migration comes from support (originally 20141110171648)
class AddAttachmentFieldsToTicket < ActiveRecord::Migration
  def change
    add_column :support_tickets, :attachment_file_name, :string
    add_column :support_tickets, :attachment_content_type, :string
    add_column :support_tickets, :attachment_file_size, :integer
    add_column :support_tickets, :attachment_updated_at, :datetime
  end
end
