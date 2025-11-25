class CreateCoreResourceControls < ActiveRecord::Migration[5.2]
  def change
    create_table :core_resource_controls do |t|
      t.datetime :last_sync_at
      t.date :started_at
      t.belongs_to :access
      t.string :status
      t.timestamps
    end
  end
end
