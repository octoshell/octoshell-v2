module Pack
  class OptionsCategory < ActiveRecord::Base
    has_many :category_values, inverse_of: :options_category,dependent: :destroy
    translates :category
    validates_translated :category, presence: true, uniqueness: true
    accepts_nested_attributes_for :category_values, allow_destroy: true
  end

end
