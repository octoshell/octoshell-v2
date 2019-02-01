class CreateCoreProjects < ActiveRecord::Migration
  def change
    create_table :core_projects do |t|
      t.string   "title",        null: false
      t.string   "state"
      t.timestamps

      t.index "state"
    end
  end
end
