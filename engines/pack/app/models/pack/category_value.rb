module Pack
  class CategoryValue < ActiveRecord::Base
    belongs_to :options_category, inverse_of: :category_values
    translates :value
    validates_translated :value, presence: true
  end
end
