# == Schema Information
#
# Table name: announcement_recipients
#
#  id              :integer          not null, primary key
#  announcement_id :integer
#  user_id         :integer
#
# Indexes
#
#  index_announcement_recipients_on_announcement_id  (announcement_id)
#  index_announcement_recipients_on_user_id          (user_id)
#
# module Announcements
  class AnnouncementRecipient < ApplicationRecord
    belongs_to :user, class_name: Announcements.user_class.to_s
    belongs_to :announcement
  end
# end
