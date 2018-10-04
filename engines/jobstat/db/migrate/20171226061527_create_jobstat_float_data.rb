class CreateJobstatFloatData < ActiveRecord::Migration
  def change
    return true
    create_table :jobstat_float_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.float :value

      t.timestamps null: false
    end
  end
end
