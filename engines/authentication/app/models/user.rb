class User < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :password, confirmation: true, length: { minimum: 6 }, on: :create
  validates :password, confirmation: true, length: { minimum: 6 }, on: :update, if: :password?
  validates :email, presence: true, uniqueness: true
  validate do
    errors.add(:email, :postmaster) if email[/postmaster/]
  end
  before_validation :downcase_email

  def activated?
    activation_state == "active"
  end

  def activation_pending?
    activation_state == "pending"
  end

  def password?
    password.present?
  end

  def send_activation_needed_email!
    Authentication::MailerWorker.perform_async(:activation_needed,
                               [email, activation_token, language])
  end

  def send_activation_success_email!
    Authentication::MailerWorker.perform_async(:activation_success, email)
  end

  def send_reset_password_email!
    Authentication::MailerWorker.perform_async(:reset_password,
                               [email, reset_password_token])
  end

  def last_login_from_ip_address=(arg)
    # stub
  end

  def downcase_email
    email.downcase! unless self.email.nil?
  end

  def self.delete_pending_users
    transaction do
      where("created_at < ? and activation_state = 'pending'",
            Date.today - Authentication.delete_after).each(&:destroy)
    end
  end
end
