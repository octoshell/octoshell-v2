class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password, confirmation: true, length: { minimum: 6 }, on: :create
  validates :password, confirmation: true, length: { minimum: 6 }, on: :update, if: :password?
  validates :email, presence: true, uniqueness: true

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
                               [email, activation_token])
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
end
