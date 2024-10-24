# This migration comes from jobstat (originally 20231114163340)
class AddUniqueIndexToJobstatJobs < ActiveRecord::Migration[5.2]
  def change
    return unless ActiveRecord::Migration.connection.index_exists? :jobstat_jobs, %i[cluster drms_task_id drms_job_id]

    add_index :jobstat_jobs, %i[cluster drms_task_id drms_job_id], unique: true,
                                                                   name: 'uniq_jobs'
  end
end
