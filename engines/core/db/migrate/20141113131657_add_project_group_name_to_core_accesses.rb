class AddProjectGroupNameToCoreAccesses < ActiveRecord::Migration
  def change
    add_column :core_accesses, :project_group_name, :string
  end
end
