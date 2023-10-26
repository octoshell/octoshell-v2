class AddNotifyAboutJobsToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :notify_about_jobs, :boolean, default: false
  end
end
