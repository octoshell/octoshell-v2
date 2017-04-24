class AccessTicketsJoinTable < ActiveRecord::Migration
  def change
  	drop_table :pack_access_tickets
    create_table :access_tickets, id: false do |t|
      t.integer :access_id
      t.integer :ticket_id
    end
 
    add_index :access_tickets, :access_id
    add_index :access_tickets, :ticket_id
  end
end
