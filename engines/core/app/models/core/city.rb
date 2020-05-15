# == Schema Information
#
# Table name: core_cities
#
#  id         :integer          not null, primary key
#  checked    :boolean          default(FALSE)
#  title_en   :string(255)
#  title_ru   :string(255)
#  country_id :integer
#
# Indexes
#
#  index_core_cities_on_country_id  (country_id)
#  index_core_cities_on_title_ru    (title_ru)
#

module Core
  class City < ApplicationRecord
    include Checkable
    belongs_to :country
    has_many :organizations
    validates :country, presence: true
    translates :title
    validates_presence_of :title_ru, :title_en, if: :checked
    validate do
      errors.add(:title_ru, :name_required) if title_ru.blank? && title_en.blank?
    end
    validates :title_ru, format: { with: /\A[а-яё№\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_russian")},
                         if: proc { |c| c.title_ru.present? && checked }
    validates :title_en, format: { with: /\A[a-z\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_english") },
                         if: proc { |c| c.title_en.present? && checked }

    scope :finder, ->(q){ where("title_ru like :q OR title_en like :q", q: "%#{q.mb_chars}%").order(:title_ru) }

    def bad
      return if country
      puts "---------------------------"
      puts inspect
      puts organizations.inspect
      if Organization.where(city: self).distinct.count(:country_id) == 1
        country = Organization.where(city: self).first.country
        puts "single country= #{country.inspect}"
      else
        puts 'not single country'
        Country.all.joins(:organizations).where("core_organizations.city_id = #{id}").each do |c|
          puts c.inspect
        end
      end
      puts "---------------------------"
    end

    def check_country
      raise "ERROR in #{inspect}" unless country
    end

    def simple_readable_attributes
      %i[title_ru title_en]
    end

    def complicated_readable_attributes
      {
        country_title_ru: country.title_ru,
        country_title_en: country.title_en
      }
    end

    def to_s
      titles
    end

    def as_json(options)
      { id: id, text: "#{title}, #{country.title}" }
    end

    def to_json_with_titles
      { id: id, text: title }
    end

    def titles
      "#{title_ru}|#{title_en}"
    end

    def merge_with!(city)
      ActiveRecord::Base.transaction do
        Organization.where(city_id: id).each do |o|
          o.update!(city: city, country: city.country)
        end
        destroy!
      end
    end

  end
end
