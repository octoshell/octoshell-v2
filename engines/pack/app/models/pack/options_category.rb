# == Schema Information
#
# Table name: pack_options_categories
#
#  id          :integer          not null, primary key
#  category_ru :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_en :string
#

module Pack
  class OptionsCategory < ApplicationRecord
    has_many :category_values, inverse_of: :options_category, dependent: :destroy
    has_many :strict_version_options, inverse_of: :options_category,
                                      class_name: 'VersionOption',
                                      foreign_key: :options_category_id,
                                      dependent: :destroy
    translates :category
    validates_translated :category, presence: true, uniqueness: true
    accepts_nested_attributes_for :category_values, allow_destroy: true
  end

end
