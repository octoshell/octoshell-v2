class CreateJobstatStringData < ActiveRecord::Migration
  def change
    return if File.exists? '/tmp/skip_bad_migrations.txt'
    create_table :jobstat_string_data do |t|
      t.string :name
      t.bigint :job_id, :index => true
      t.string :value

      t.timestamps null: false
    end
  end
end
