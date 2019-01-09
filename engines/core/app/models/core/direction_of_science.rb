module Core
  class DirectionOfScience < ActiveRecord::Base
    has_and_belongs_to_many :projects, join_table: "core_direction_of_sciences_per_projects"

    translates :name
    validates_translated :name, presence: true

    def to_s
      name
    end
  end
end
