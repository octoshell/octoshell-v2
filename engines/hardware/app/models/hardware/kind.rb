module Hardware
  class Kind < ActiveRecord::Base
    translates :name, :description, fallback: :any
    validates_translated :name, presence: true
    validates :name_ru, uniqueness: true, if: proc { |k| k.name_ru.present? }
    validates :name_en, uniqueness: true, if: proc { |k| k.name_en.present? }

    after_create do
      states.create!(name_en: 'deleted', name_ru: 'удалено')
    end

    has_many :states, inverse_of: :kind, dependent: :destroy
    # has_many :items_states, inverse_of: :kind, dependent: :destroy
    has_many :items, inverse_of: :kind, dependent: :destroy

  end
end
