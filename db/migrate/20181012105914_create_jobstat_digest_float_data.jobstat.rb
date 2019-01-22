# This migration comes from jobstat (originally 20171226061606)
class CreateJobstatDigestFloatData < ActiveRecord::Migration
  def change
    return if File.exists? '/tmp/skip-octoshell-bad-migrations'
    create_table :jobstat_digest_float_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.float :value
      t.datetime :time

      t.timestamps null: false
    end
  end
end
