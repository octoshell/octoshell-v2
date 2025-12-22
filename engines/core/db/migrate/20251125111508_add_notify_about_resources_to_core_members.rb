class AddNotifyAboutResourcesToCoreMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :core_members, :notify_about_resources, :boolean, default: false
  end
end
