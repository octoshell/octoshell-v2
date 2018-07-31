module Core
  class City < ActiveRecord::Base
    include Checkable
    belongs_to :country
    has_many :organizations
    validates :country, presence: true
    validates_presence_of :title_ru, :title_en, if: :checked
    validate do
      errors.add(:title_ru, :name_required) if title_ru.blank? && title_en.blank?
    end
    validates :title_ru, format: { with: /\A[а-яё№\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_russian")},
                         if: 'title_ru.present? && checked'
    validates :title_en, format: { with: /\A[a-z\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_english") },
                         if: 'title_en.present? && checked'

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
      { id: id, text: title_ru }
    end

    def to_json_with_titles
      { id: id, text: titles }
    end

    def titles
      "#{title_ru}|#{title_en}"
    end
  end
end
