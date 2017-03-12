# This migration comes from pack (originally 20170312173117)
class Pseudo2FinalChanges < ActiveRecord::Migration
  def change
  	add_column :pack_accesses,:support_ticket_id,:integer
  end
end
