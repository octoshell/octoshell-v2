# This migration comes from core (originally 20251125111508)
class AddNotifyAboutResourcesToCoreMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :core_members, :notify_about_resources, :boolean, default: false
  end
end
