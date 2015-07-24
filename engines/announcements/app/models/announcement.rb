class Announcement < ActiveRecord::Base
  has_many :announcement_recipients
  has_many :recipients, class_name: "User", source: :user, through: :announcement_recipients

  mount_uploader :attachment, Announcements::AttachmentUploader

  validates :title, :body, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :delivered

    event :deliver do
      transition :pending => :delivered
    end

    inside_transition on: :deliver, &:send_mails
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
