class AddBlockEmailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :block_emails, :boolean, default: false
  end
end
