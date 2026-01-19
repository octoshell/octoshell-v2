# == Schema Information
#
# Table name: pack_category_values
#
#  id                  :integer          not null, primary key
#  value_en            :string
#  value_ru            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  options_category_id :integer
#
# Indexes
#
#  index_pack_category_values_on_options_category_id  (options_category_id)
#

module Pack
  class CategoryValue < ApplicationRecord
    belongs_to :options_category, inverse_of: :category_values
    has_many :version_options, inverse_of: :category_value, dependent: :destroy
    translates :value
    validates_translated :value, presence: true
    scope :finder, lambda { |q|
      where('lower(value_ru) like lower(:q) OR lower(value_en) like lower(:q)', q: "%#{q.mb_chars}%")
    }

    def as_json(_param = nil)
      { id: id, text: value }
    end
  end
end
