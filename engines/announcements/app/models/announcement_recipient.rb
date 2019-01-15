class AnnouncementRecipient < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  belongs_to :announcement
end
