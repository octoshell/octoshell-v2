class CreateJobstatJobs < ActiveRecord::Migration
  def change
    create_table :jobstat_jobs do |t|
      t.bigint :job_id
      t.string :login, :index => true
      t.string :partition, :index => true
      t.string :account
      t.datetime :submit_time, :index => true
      t.datetime :start_time, :index => true
      t.datetime :end_time, :index => true
      t.bigint :timelimit
      t.string :job_name
      t.string :state, :limit => 2, :index => true
      t.bigint :priority
      t.bigint :req_cpus
      t.bigint :alloc_cpus
      t.string :nodelist

      t.timestamps null: false
    end
  end
end
