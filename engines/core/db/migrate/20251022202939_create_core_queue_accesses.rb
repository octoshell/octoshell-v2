class CreateCoreQueueAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :core_queue_accesses do |t|
      t.belongs_to :access
      t.belongs_to :partition
      t.string :status
      t.timestamps
    end
  end
end
