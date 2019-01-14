# This migration comes from announcements (originally 20150306133356)
class AddReceiveMailsOptionsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :receive_info_mails, :boolean, default: true
    add_column :profiles, :receive_special_mails, :boolean, default: true
  end
end
