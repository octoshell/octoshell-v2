module Core
  class Credential < ActiveRecord::Base
    belongs_to :user, class_name: Core.user_class,
                      foreign_key: :user_id, inverse_of: :credentials

    validates :user, :public_key, :name, presence: true
    validates :public_key, uniqueness: { scope: [:user_id] }
    validate :public_key_validator, unless: ->{ deactivated? }

    after_save :synchronize_user_projects

    state_machine initial: :active do
      state :active
      state :deactivated

      event :reactivate do
        transition :deactivated => :active
      end

      event :deactivate do
        transition :active => :deactivated
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
