class CreateCoreCards < ActiveRecord::Migration
  def change
    create_table :core_project_cards do |t|
      t.integer :project_id
      t.text :name
      t.text :en_name
      t.text :driver
      t.text :en_driver
      t.text :strategy
      t.text :en_strategy
      t.text :objective
      t.text :en_objective
      t.text :impact
      t.text :en_impact
      t.text :usage
      t.text :en_usage

      t.timestamps
      t.index :project_id
    end
  end
end
