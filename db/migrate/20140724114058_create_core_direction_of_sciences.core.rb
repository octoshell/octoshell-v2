# This migration comes from core (originally 20140722122657)
class CreateCoreDirectionOfSciences < ActiveRecord::Migration
  def change
    create_table :core_direction_of_sciences do |t|
      t.string :name
      t.timestamps
    end

    create_table :core_direction_of_sciences_per_projects do |t|
      t.integer :direction_of_science_id
      t.integer :project_id

      t.index :direction_of_science_id, name: :idos_on_dos_per_projects
      t.index :project_id, name: :iproject_on_dos_per_projects
    end
  end
end
