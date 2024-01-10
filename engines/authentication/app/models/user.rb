# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  access_state                    :string(255)
#  activation_state                :string(255)
#  activation_token                :string(255)
#  activation_token_expires_at     :datetime
#  crypted_password                :string(255)
#  deleted_at                      :datetime
#  email                           :string(255)      not null
#  language                        :string
#  last_activity_at                :datetime
#  last_login_at                   :datetime
#  last_login_from_ip_address      :string(255)
#  last_logout_at                  :datetime
#  remember_me_token               :string(255)
#  remember_me_token_expires_at    :datetime
#  reset_password_email_sent_at    :datetime
#  reset_password_token            :string(255)
#  reset_password_token_expires_at :datetime
#  salt                            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#
# Indexes
#
#  index_users_on_activation_token      (activation_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_last_login_at         (last_login_at)
#  index_users_on_remember_me_token     (remember_me_token)
#  index_users_on_reset_password_token  (reset_password_token)
#

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :profile, class_name: Profile.to_s
  validates :password, confirmation: true, length: { minimum: 6 }, on: :create
  validates :password, confirmation: true, length: { minimum: 6 }, on: :update, if: :password?
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validate do
    errors.add(:email, :postmaster) if email && email[/postmaster/]
  end
  before_validation do
    self.email = email.downcase if email.present?
  end

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

  def self.delete_pending_users
    transaction do
      where("created_at < ? and activation_state = 'pending'",
            Date.today - Authentication.delete_after).each(&:destroy)
    end
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
