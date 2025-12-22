module Core
  class ResourceUser < ApplicationRecord
    belongs_to :access, inverse_of: :resource_users
    belongs_to :user, class_name: '::User'
    validates :access, presence: true
    validates :email, presence: true, uniqueness: { scope: :access_id }, unless: :user
    validates :user, presence: true, uniqueness: { scope: :access_id }, unless: -> { email.present? }

    def user_or_plain_email
      user&.email || email
    end
  end
end
