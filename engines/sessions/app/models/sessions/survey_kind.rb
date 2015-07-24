module Sessions
  class SurveyKind < ActiveRecord::Base
    has_many :surveys

    validates :name, presence: true
  end
end
