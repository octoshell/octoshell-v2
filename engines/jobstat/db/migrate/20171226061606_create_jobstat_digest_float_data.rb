class CreateJobstatDigestFloatData < ActiveRecord::Migration
  def change
    create_table :jobstat_digest_float_data do |t|
      t.string :name
      t.bigint :task_id, :index => true
      t.float :value
      t.datetime :time

      t.timestamps null: false
    end
  end
end
