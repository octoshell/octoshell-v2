class CreateCloudComputingApiLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_api_logs do |t|
      t.belongs_to :virtual_machine
      t.belongs_to :item
      t.text :log
      t.string :action
      t.timestamps
    end
  end
end
