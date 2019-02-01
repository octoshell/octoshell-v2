# == Schema Information
#
# Table name: core_project_invitations
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  user_fio   :string(255)      not null
#  user_email :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  language   :string           default("ru")
#

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
