# == Schema Information
#
# Table name: announcements
#
#  id            :integer          not null, primary key
#  attachment    :string(255)
#  body_en       :text
#  body_ru       :text
#  is_special    :boolean
#  reply_to      :string(255)
#  state         :string(255)
#  title_en      :string
#  title_ru      :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  created_by_id :integer
#
# Indexes
#
#  index_announcements_on_created_by_id  (created_by_id)
#

class Announcement < ActiveRecord::Base

  has_paper_trail

  translates :title, :body

  has_many :announcement_recipients, dependent: :destroy
  has_many :recipients, class_name: "User", source: :user, through: :announcement_recipients
  belongs_to :created_by, class_name: 'User'
  mount_uploader :attachment, Announcements::AttachmentUploader

  validates_translated :body, :title, presence: true
  include AASM
  include ::AASM_Additions
  aasm :state, :column => :state do
    state :pending, :initial => true
    state :delivered

    event :deliver do
      transitions :from => :pending, :to => :delivered, :after => :send_mails
    end

    #after_transition on: :deliver, &:send_mails #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!FIX
  end

  def send_mails
    announcement_recipients.find_each do |recipient|
      Announcements::MailerWorker.perform_async(:announcement, recipient.id)
    end
  end

  def test_send(test_user)
    recipient = announcement_recipients.where(user: test_user).first_or_create!
    Announcements::MailerWorker.perform_async(:announcement, recipient.id)
  end
end
