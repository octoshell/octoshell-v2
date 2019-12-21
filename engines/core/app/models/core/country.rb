# == Schema Information
#
# Table name: core_countries
#
#  id       :integer          not null, primary key
#  title_ru :string(255)
#  title_en :string(255)
#  checked  :boolean          default(FALSE)
#

module Core
  class Country < ApplicationRecord
    include Checkable
    has_many :organizations,through: :cities
    has_many :cities, inverse_of: :country, dependent: :destroy
    translates :title
    validates_presence_of :title_ru, :title_en, if: :checked
    validate do
      errors.add(:title_ru, :name_required) if title_ru.blank? && title_en.blank?
    end
    validates :title_ru, format: { with: /\A[а-яё№\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_russian")},
                         if: proc { |c| c.title_ru.present? }
    validates :title_en, format: { with: /\A[a-z\d[:space:][:punct:]\+]+\z/i,
                                   message: I18n.t("errors.must_be_in_english") },
                         if:  proc { |c| c.title_en.present? }
    scope :finder, ->(q){ where("title_ru like :q OR title_en like :q", q: "%#{q.mb_chars}%").order(:title_ru) }

    def to_s
      titles
    end

    def simple_readable_attributes
      %i[title_ru title_en]
    end

    def titles
      "#{title_ru}|#{title_en}"
    end

    def to_json_with_titles
      { id: id, text: titles }
    end
  end
end
