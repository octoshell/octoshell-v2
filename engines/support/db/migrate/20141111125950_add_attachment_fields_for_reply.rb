class AddAttachmentFieldsForReply < ActiveRecord::Migration
  def change
    add_column :support_replies, :attachment_file_name, :string
    add_column :support_replies, :attachment_content_type, :string
    add_column :support_replies, :attachment_file_size, :integer
    add_column :support_replies, :attachment_updated_at, :datetime
  end
end
