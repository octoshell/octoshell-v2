class Announcement < ActiveRecord::Base

  has_many :announcement_recipients
  has_many :recipients, class_name: "User", source: :user, through: :announcement_recipients

  mount_uploader :attachment, Announcements::AttachmentUploader

  validates :title, :body, presence: true

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
