class Pseudo2FinalChanges < ActiveRecord::Migration
  def change
  	add_column :pack_accesses,:support_ticket_id,:integer
  end
end
