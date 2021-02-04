class CreateCloudComputingVirtualMachines < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_virtual_machines do |t|
      t.integer :identity
      t.belongs_to :item
      t.string :address
      t.string :state
      t.string :lcm_state
      t.datetime :last_info
      t.timestamps
    end
  end
end
