# This migration comes from core (originally 20230517171302)
class CreateCoreProjectVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :core_project_versions do |t|
      t.datetime :created_at, null: false
      t.belongs_to :project, null: false
      t.text :object
      t.text :object_changes
    end
  end
end
