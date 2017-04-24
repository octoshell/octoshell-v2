# This migration comes from pack (originally 20170421073629)
class CreatePackAccessTickets < ActiveRecord::Migration
  def change
    create_table :pack_access_tickets do |t|

      t.belongs_to :ticket
      t.belongs_to :access
      t.timestamps null: false
    end
  end
end
