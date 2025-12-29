# == Schema Information
#
# Table name: options_categories
#
#  id         :integer          not null, primary key
#  name_ru    :string
#  name_en    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OptionsCategory < ApplicationRecord
  has_many :category_values, inverse_of: :options_category, dependent: :destroy
  has_many :strict_options, inverse_of: :options_category,
                            class_name: '::Option',
                            foreign_key: :options_category_id,
                            dependent: :destroy
  translates :name
  validates_translated :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :category_values, allow_destroy: true
  scope :finder, lambda { |q|
    where('lower(name_ru) like lower(:q) OR lower(name_en) like lower(:q)', q: "%#{q.mb_chars}%").limit(10)
  }

  def as_json(_param = nil)
    { id: id, text: name }
  end
end
