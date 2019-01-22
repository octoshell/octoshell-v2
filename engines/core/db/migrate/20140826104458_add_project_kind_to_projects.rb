class AddProjectKindToProjects < ActiveRecord::Migration
  def change
    add_column :core_projects, :kind_id, :integer
    add_index :core_projects, :kind_id
  end
end
