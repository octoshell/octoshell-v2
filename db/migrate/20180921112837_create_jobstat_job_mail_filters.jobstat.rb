# This migration comes from jobstat (originally 20180921111132)
class CreateJobstatJobMailFilters < ActiveRecord::Migration
  def change
    create_table :jobstat_job_mail_filters do |t|
      t.string :condition
      t.integer :user_id

    end
  end
end
