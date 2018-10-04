class CreateJobstatDigestStringData < ActiveRecord::Migration
  def change
    return true
    create_table :jobstat_digest_string_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.string :value
      t.datetime :time

      t.timestamps null: false
    end
  end
end
