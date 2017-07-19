module Core
  class ProjectInvitation < ActiveRecord::Base
    belongs_to :project

    after_create :send_email_to_user
    before_create :downcase_email

    def send_email_to_user
      Core::MailerWorker.perform_async(:invitation_to_octoshell, self.id)
      touch
    end

    def downcase_email user
      user.email.downcase! if user.email
    end
  end
end
