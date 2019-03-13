# == Schema Information
#
# Table name: core_project_invitations
#
#  id         :integer          not null, primary key
#  language   :string           default("ru")
#  user_email :string(255)      not null
#  user_fio   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer          not null
#
# Indexes
#
#  index_core_project_invitations_on_project_id  (project_id)
#

module Core
  class ProjectInvitation < ActiveRecord::Base
    belongs_to :project

    after_commit :send_email_to_user, on: :create

    def send_email_to_user_with_save
      send_email_to_user
      touch
    end

    def send_email_to_user
      Core::MailerWorker.perform_async(:invitation_to_octoshell, [id, language])
    end

  end
end
