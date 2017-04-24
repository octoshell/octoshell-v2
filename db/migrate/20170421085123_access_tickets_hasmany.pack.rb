# This migration comes from pack (originally 20170421084814)
class AccessTicketsHasmany < ActiveRecord::Migration
  def change
  	remove_column :pack_accesses,:support_ticket_id
  end
end
