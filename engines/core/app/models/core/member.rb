module Core
  class Member < ActiveRecord::Base
    belongs_to :user, class_name: Core.user_class, foreign_key: :user_id, inverse_of: :accounts
    belongs_to :project, inverse_of: :members
    belongs_to :organization
    belongs_to :organization_department

    delegate :full_name, :email, :credentials, :sured?, to: :user

    state_machine :project_access_state, initial: :invited do
      state :invited   # приглашён, не подтвердил участие
      state :engaged   # принял приглашение (заполнил организации)
      state :unsured   # упомянут в ещё не активированном поручительстве
      state :allowed   # поручительство подписано и одобрено администрацией
      state :denied
      state :suspended # участие приостановлено, т.к. проект неактивен

      event :accept_invitation do
        transition :invited => :engaged
      end

      event :append_to_surety do
        transition :engaged => :unsured
      end

      event :substract_from_surety do
        transition [:allowed, :unsured] => :engaged
      end

      event :activate do
        transition [:unsured, :suspended] => :allowed
      end

      event :deny do
        transition :allowed => :denied
      end

      event :allow do
        transition :denied => :allowed
      end

      event :suspend do
        transition :allowed => :suspended
      end

      after_transition :unsured => :allowed do |member, _|
        Core::MailerWorker.perform_async(:access_to_project_granted, member.id)
        if member.project.pending? && member.project.accesses.with_state(:opened).any?
          member.project.activate!
        end
      end

      after_transition :allowed => :denied do |member, _|
        Core::MailerWorker.perform_async(:access_to_project_denied, member.id)
      end

      after_transition [:denied, :suspended] => :allowed do |member, _|
        Core::MailerWorker.perform_async(:access_to_project_granted, member.id)
      end
    end

    def create_or_update
      assign_login if new_record?
      super
    end

    def toggle_project_access_state!
      if allowed?
        deny!
      elsif denied?
        allow!
      end
    end

    def has_access_to_clusters?
      project.active? && user.prepared_to_join_projects? && allowed?
    end

    def assign_login
      new_login = email.delete(".+_-")[/^(.+)@/, 1].downcase
      self.login = "#{new_login[0,24]}_#{project.id}"
    end
  end
end
