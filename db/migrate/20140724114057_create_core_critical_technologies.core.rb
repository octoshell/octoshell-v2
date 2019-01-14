# This migration comes from core (originally 20140722104917)
class CreateCoreCriticalTechnologies < ActiveRecord::Migration
  def change
    create_table :core_critical_technologies do |t|
      t.string :name
      t.timestamps
    end

    create_table :core_critical_technologies_per_projects do |t|
      t.integer :critical_technology_id
      t.integer :project_id

      t.index :critical_technology_id, name: :icrittechs_on_critical_technologies_per_projects
      t.index :project_id, name: :iprojects_on_critical_technologies_per_projects
    end
  end
end
