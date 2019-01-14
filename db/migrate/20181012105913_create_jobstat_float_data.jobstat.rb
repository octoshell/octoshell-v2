# This migration comes from jobstat (originally 20171226061527)
class CreateJobstatFloatData < ActiveRecord::Migration
  def change
    return if File.exists? '/tmp/skip-octoshell-bad-migrations'
    create_table :jobstat_float_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.float :value

      t.timestamps null: false
    end
  end
end
