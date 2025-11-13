class CreateCoreResourceControlFields < ActiveRecord::Migration[5.2]
  def change
    create_table :core_resource_control_fields do |t|
      t.belongs_to :resource_control
      t.belongs_to :quota_kind
      t.float :cur_value
      t.float :limit
      t.timestamps
    end
  end
end
