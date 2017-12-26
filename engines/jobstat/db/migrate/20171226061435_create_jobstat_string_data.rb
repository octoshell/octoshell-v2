class CreateJobstatStringData < ActiveRecord::Migration
  def change
    create_table :jobstat_string_data do |t|
      t.string :name
      t.bigint :task_id, :index => true
      t.string :value

      t.timestamps null: false
    end
  end
end
