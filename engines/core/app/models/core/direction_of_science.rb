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
    has_and_belongs_to_many :projects, join_table: "core_direction_of_sciences_per_projects"

    translates :name
    validates_translated :name, presence: true

    def to_s
      name
    end
  end
end
