module Core
  class ProjectInvitation < ActiveRecord::Base
    belongs_to :project

    after_create :send_email_to_user

    def send_email_to_user
      Core::MailerWorker.perform_async(:invitation_to_octoshell, [id, language])
      touch
    end

  end
end
