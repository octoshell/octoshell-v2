class CreateCoreResearchAreas < ActiveRecord::Migration
  def change
    create_table :core_research_areas do |t|
      t.string :name
      t.string :group
      t.timestamps
    end

    create_table :core_research_areas_per_projects do |t|
      t.integer :research_area_id
      t.integer :project_id

      t.index :research_area_id, name: :ira_on_ira_per_projects
      t.index :project_id, name: :iproject_on_ira_per_projects
    end
  end
end
