# == Schema Information
#
# Table name: category_values
#
#  id                  :integer          not null, primary key
#  options_category_id :integer
#  value_ru            :string
#  value_en            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class CategoryValue < ActiveRecord::Base
  belongs_to :options_category, inverse_of: :category_values
  has_many :options, inverse_of: :category_value, dependent: :destroy
  translates :value
  validates_translated :value, presence: true
  scope :finder, ->(q) { where("lower(value_ru) like lower(:q) OR lower(value_en) like lower(:q)", q: "%#{q.mb_chars}%") }

  def as_json(_param)
    { id: id, text: value }
  end
end
