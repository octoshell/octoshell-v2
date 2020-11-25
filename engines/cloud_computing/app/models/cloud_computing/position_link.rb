module CloudComputing
  class PositionLink < ApplicationRecord
    belongs_to :from, class_name: 'CloudComputing::Position', inverse_of: :from_links
    belongs_to :to, class_name: 'CloudComputing::Position', inverse_of: :to_links
  end
end
