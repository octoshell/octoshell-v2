class CreateCloudComputingApiLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_api_logs do |t|
      t.belongs_to :nebula_identity
      t.belongs_to :position
      t.text :log
      t.string :action
      t.timestamps
    end
  end
end
