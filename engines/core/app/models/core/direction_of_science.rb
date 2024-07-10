# == Schema Information
#
# Table name: core_direction_of_sciences
#
#  id         :integer          not null, primary key
#  name_ru    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string
#

module Core
  class DirectionOfScience < ApplicationRecord
    has_many :project_direction_of_sciences, inverse_of: :direction_of_science
    has_many :projects, through: :project_direction_of_sciences, inverse_of: :direction_of_sciences

    translates :name
    validates_translated :name, presence: true

    def to_s
      name
    end
  end
end
