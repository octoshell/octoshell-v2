# This migration comes from jobstat (originally 20171226061628)
class CreateJobstatDigestStringData < ActiveRecord::Migration
  def change
    create_table :jobstat_digest_string_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.string :value
      t.datetime :time

      t.timestamps null: false
    end
  end
end
