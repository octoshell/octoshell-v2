class AddDateFieldsToCoreProjects < ActiveRecord::Migration
  def change
    add_column :core_projects, :first_activation_at, :datetime
    add_column :core_projects, :finished_at, :datetime
    add_column :core_projects, :estimated_finish_date, :datetime
  end
end
