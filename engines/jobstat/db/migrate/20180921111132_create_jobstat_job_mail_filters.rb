class CreateJobstatJobMailFilters < ActiveRecord::Migration
  def change
    return if File.exists? '/tmp/skip_bad_migrations.txt'
    create_table :jobstat_job_mail_filters do |t|
      t.string :condition
      t.integer :user_id

    end
  end
end
