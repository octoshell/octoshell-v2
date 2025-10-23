# This migration comes from core (originally 20251022202939)
class CreateCoreQueueAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :core_queue_accesses do |t|
      t.belongs_to :resource_control
      t.belongs_to :partition
      t.timestamps
    end
  end
end
