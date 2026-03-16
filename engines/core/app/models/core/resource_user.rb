module Core
  class ResourceUser < ApplicationRecord
    belongs_to :access, inverse_of: :resource_users
    belongs_to :member, class_name: 'Core::Member'
    has_one :user, through: :member
    validates :access, presence: true
    validates :email, presence: true, uniqueness: { scope: :access_id }, unless: :member
    validates :member, presence: true, uniqueness: { scope: :access_id }, unless: -> { email.present? }

    validate :member_must_belong_to_project, if: :member

    def user_or_plain_email
      member&.user&.email || email
    end

    private

    def member_must_belong_to_project
      return unless access && member

      return if member.project == access.project

      errors.add(:member, :must_belong_to_project)
    end
  end
end
