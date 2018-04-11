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
                                   message: I18n.t(".errors.must_be_in_russian")},
                         if: 'title_ru.present? && checked'
    validates :title_en, format: { with: /\A[a-z\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t(".errors.must_be_in_english") },
                         if: 'title_en.present? && checked'

    scope :finder, ->(q){ where("title_ru like :q OR title_en like :q", q: "%#{q.mb_chars}%").order(:title_ru) }

    #console only
    def check_country
      return if country
      input = ''
      if Organization.where(city: self).distinct.count(:country_id) == 1
        country = Organization.where(city: self).first.country
        loop do
          STDOUT.puts "Is city #{self.inspect} in #{country.inspect}? (y/n)"
          input = STDIN.gets.strip.downcase
          break if  %w(y n).include?(input)
        end
        if input == 'y'
          self.country = country
        else
          STDOUT.puts "Print country's title_en for #{self.inspect}"
          input = STDIN.gets.strip
          country = Country.find_or_create_by!(title_en: input)
          self.country = country
        end
        puts "Country for  #{self.inspect} #{'is modified to'.yellow} #{country.inspect}"
      else
        STDOUT.puts "Print country's title_en for #{self.inspect}"
        input = STDIN.gets.strip
        country = Country.find_or_create_by!(title_en: input)
        self.country = country
      end
      save!
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
