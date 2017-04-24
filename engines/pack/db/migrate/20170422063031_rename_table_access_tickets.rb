class RenameTableAccessTickets < ActiveRecord::Migration
  def change
  	rename_table :access_tickets,:pack_access_tickets
  end
end
