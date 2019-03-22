# == Schema Information
#
# Table name: hardware_kinds
#
#  id             :integer          not null, primary key
#  name_ru        :string
#  name_en        :string
#  description_ru :text
#  description_en :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

module Hardware
  class Kind < ApplicationRecord
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
