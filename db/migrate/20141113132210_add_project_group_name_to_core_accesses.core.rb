# This migration comes from core (originally 20141113131657)
class AddProjectGroupNameToCoreAccesses < ActiveRecord::Migration[4.2]
  def change
    add_column :core_accesses, :project_group_name, :string
  end
end
