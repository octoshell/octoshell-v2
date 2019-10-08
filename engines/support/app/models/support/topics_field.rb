module Support
  class TopicsField < ApplicationRecord
    belongs_to :field, inverse_of: :topics_fields
    belongs_to :topic, inverse_of: :topics_fields
    has_many :field_values, inverse_of: :topics_fields
    # translates :name
    # validates_translated :name, presence: true
  end
end
