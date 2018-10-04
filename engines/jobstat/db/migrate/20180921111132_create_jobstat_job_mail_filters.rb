class CreateJobstatJobMailFilters < ActiveRecord::Migration
  def change
    return true
    create_table :jobstat_job_mail_filters do |t|
      t.string :condition
      t.integer :user_id

    end
  end
end
