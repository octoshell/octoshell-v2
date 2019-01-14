class CreateCoreProjectKinds < ActiveRecord::Migration
  def change
    create_table :core_project_kinds do |t|
      t.string :name
    end
  end
end
