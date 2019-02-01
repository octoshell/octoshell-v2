# == Schema Information
#
# Table name: sessions_survey_kinds
#
#  id   :integer          not null, primary key
#  name :string(255)
#

module Sessions
  class SurveyKind < ActiveRecord::Base
    has_many :surveys

    validates :name, presence: true
  end
end
