module Core
  class Country < ActiveRecord::Base
    has_many :cities, inverse_of: :country, dependent: :destroy

    scope :finder, ->(q){ where("title_ru like :q OR title_en like :q", q: "%#{q.mb_chars}%").order(:title_ru) }

    def to_s
      title_ru
    end
  end
end
