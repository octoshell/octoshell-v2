class CreateCloudComputingNebulaIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_nebula_identities do |t|
      t.integer :identity
      t.belongs_to :position
      t.string :address
      t.timestamps
    end
  end
end
