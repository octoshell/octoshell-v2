class CreateJobstatDigestStringData < ActiveRecord::Migration
  def change
    create_table :jobstat_digest_string_data do |t|
      t.string :name
      t.bigint :task_id, :index => true
      t.string :value
      t.datetime :time

      t.timestamps null: false
    end
  end
end
