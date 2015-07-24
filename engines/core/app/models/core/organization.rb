module Core
  class Organization < ActiveRecord::Base
    belongs_to :kind, class_name: "Core::OrganizationKind", foreign_key: :kind_id
    belongs_to :country
    belongs_to :city

    has_many :departments, class_name: "::Core::OrganizationDepartment", inverse_of: :organization

    has_many :employments, inverse_of: :organization
    has_many :users, class_name: Core.user_class, through: :employments, inverse_of: :organizations

    has_many :projects, inverse_of: :organization

    after_create :notify_admins

    accepts_nested_attributes_for :departments, allow_destroy: true

    scope :finder, lambda { |q| where("lower(name) like :q OR lower(abbreviation) like :q",
                                      q: "%#{q.mb_chars.downcase}%").order("name asc") }

    validates :name, presence: true

    def self.MSU
      find(497)
    end

    def to_s
      short_name
    end

    def as_json(options)
      { id: id, text: name }
    end

    def city_title
      city.try(:title_ru)
    end

    def city_title=(title)
      self.city = country.cities.where(title_ru: title.mb_chars).first_or_create! if title.present? && country.present?
    end

    def short_name
      abbreviation.presence || name
    end

    def full_name
      "#{name} #{abbreviation}"
    end

    def notify_admins
      Core::MailerWorker.perform_async(:new_organization, id)
    end
  end
end
