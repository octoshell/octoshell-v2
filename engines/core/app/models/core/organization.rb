# == Schema Information
#
# Table name: core_organizations
#
#  id           :integer          not null, primary key
#  abbreviation :string(255)
#  checked      :boolean          default(FALSE)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  city_id      :integer
#  country_id   :integer
#  kind_id      :integer
#
# Indexes
#
#  index_core_organizations_on_city_id     (city_id)
#  index_core_organizations_on_country_id  (country_id)
#  index_core_organizations_on_kind_id     (kind_id)
#

module Core
  class Organization < ApplicationRecord
    octo_use(:stat_class, :sessions, 'Stat')
    remove_spaces :name
    MERGED_ASSOC = [Employment, Member, Project, SuretyMember].freeze
    include MergeOrganzations
    include Checkable
    belongs_to :kind, class_name: "Core::OrganizationKind", foreign_key: :kind_id
    belongs_to :country
    belongs_to :city

    has_many :departments, class_name: "::Core::OrganizationDepartment", inverse_of: :organization

    has_many :employments, inverse_of: :organization, autosave: true
    has_many :users, class_name: Core.user_class.to_s, through: :employments, inverse_of: :organizations

    has_many :projects, inverse_of: :organization

    has_many :members, inverse_of: :organization

    has_many :surety_members, inverse_of: :organization
    if Octoface.role_class?(:sessions, 'Stat')
      has_many :sessions_stats, inverse_of: :organization, class_name: stat_class.to_s
    end
    after_create :notify_admins

    accepts_nested_attributes_for :departments, allow_destroy: true
    accepts_nested_attributes_for :city, allow_destroy: false

    scope :finder, lambda { |q| where("lower(name) like :q OR lower(abbreviation) like :q OR CAST(id AS TEXT) like :q",
                                      q: "%#{q.mb_chars.downcase}%").order("name asc") }

    validates :name, :city, :country, presence: true
    validate do
      errors.add(:city_id, :dif) if city && city.country != country
    end

    def destroy_allowed?
      disallow = employments.where(state: 'active').exists? ||
                 members.exists? ||
                 surety_members.exists? ||
                 (Octoface.role_class?(:sessions, 'Stat') && sessions_stats.exists?) ||
                 projects.exists? ||
                 department_mergers_any?
      !disallow
    end

    def can_edit?(current_user)
      main_user = employments.order(:created_at).first.try(:user)
      main_user == current_user
    end

    def check_location
      unless country
        puts "Modifying country for #{self.inspect} "
        self.country = Country.find_or_create_by!(title_en: 'Unknown')
      end
      unless city
        puts "Modifying city for #{self.inspect} "
        self.city = City.find_or_create_by!(title_en: 'Unknown', country: country)
      end
      if invalid? && errors[:city_id]
        if city.country
          puts "#{self.inspect} Organization city #{city.inspect.green} isn't located in organization country #{country.inspect.blue}. Solve this problem before merge and run this script again"
        else
          puts "Country is not specified for #{city.inspect}".red
        end
        return
      end
      save!
    end

    def self.MSU
      find(497)
    end

    def to_s
      short_name
    end

    def as_json(_options)
      full_json
    end

    def city_title
      city.try(:title_ru)
    end

    def city_title_en
      city.try(:title_ru)
    end


    def city_title=(title)
      self.city = country.cities.where(City.current_locale_column(:title) => title.mb_chars).first_or_initialize if title.present? && country.present?
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

    def name_with_id
      "#{id}|#{name}"
    end

    def full_json
      { id: id, text: name_with_id }
    end

    def simple_readable_attributes
      %i[name abbreviation]
    end

    def complicated_readable_attributes
      {
        kind_id: kind.to_s,
        country_id: country.titles,
        city_id: city.titles
      }
    end
  end
end
