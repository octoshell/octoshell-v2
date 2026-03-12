# This migration comes from core (originally 20260308095507)
class DropCoreQueueAccess < ActiveRecord::Migration[7.2]
  def change
    drop_table :core_queue_accesses
  end
end
