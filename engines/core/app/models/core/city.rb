module Core
  class City < ActiveRecord::Base
    belongs_to :country

    scope :finder, ->(q){ where("title_ru like :q OR title_en like :q", q: "%#{q.mb_chars}%").order(:title_ru) }

    def to_s
      title_ru
    end

    def as_json(options)
      { id: id, text: title_ru }
    end
  end
end
