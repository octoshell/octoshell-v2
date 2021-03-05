class CreateCloudComputingItemLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :cloud_computing_item_links do |t|
      t.belongs_to :from
      t.belongs_to :to
      t.timestamps
    end
  end
end
