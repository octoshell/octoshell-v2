module Core
  class OrganizationDepartment < ActiveRecord::Base
    belongs_to :organization, inverse_of: :departments

    has_many :projects

    has_many :employments, inverse_of: :organization_department
    has_many :users, class_name: Core.user_class, through: :employments

    after_create :notify_admins

    scope :finder, ->(q){ where("name like :q", q: "%#{q.mb_chars}%").order(:name) }

    validates :name, :organization, presence: true

    def to_s
      name
    end

    def full_name
      "#{organization.short_name}, #{name}"
    end

    def as_json(options)
      { id: id, text: name }
    end

    def notify_admins
      Core::MailerWorker.perform_async(:new_organization_department, id)
    end
  end
end
