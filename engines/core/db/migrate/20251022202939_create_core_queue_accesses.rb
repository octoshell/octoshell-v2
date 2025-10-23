class CreateCoreQueueAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :core_queue_accesses do |t|
      t.belongs_to :resource_control_field
      t.belongs_to :partition
      t.float :cur_amount
      t.timestamps
    end
  end
end
