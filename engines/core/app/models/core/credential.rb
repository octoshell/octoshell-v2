module Core
  class Credential < ActiveRecord::Base

    belongs_to :user, class_name: Core.user_class,
                      foreign_key: :user_id, inverse_of: :credentials

    validates :user, :public_key, :name, presence: true
    validates :public_key, uniqueness: { scope: [:user_id] }
    validate :public_key_validator, unless: ->{ deactivated? }

    after_save :synchronize_user_projects

    include AASM
    include ::AASM_Additions
    aasm(:state, :column => :state) do
      state :active, :initial => true
      state :deactivated

      event :reactivate do
        transitions :from => :deactivated, :to => :active
      end

      event :deactivate do
        transitions :from => :active, :to => :deactivated
      end
    end

    def activate_or_create
      if credential = user.credentials.find_by_public_key(public_key)
        credential.active? || credential.reactivate
      else
        save
      end
    end

    def public_key=(key)
      key.delete!("^\u{0000}-\u{007F}")
      self[:public_key] = key
    end

    def public_key_validator
      if public_key =~ /private/i
        errors.add(:public_key, I18n.t(".errors.private_key_supplied"))
      end
      unless SSHKey.valid_ssh_public_key?(public_key)
        errors.add(:public_key, I18n.t(".errors.wrong_key"))
      end
    end

    private

    def synchronize_user_projects
      user.available_projects.each(&:synchronize!)
    end
  end
end
