module Core
  class CriticalTechnology < ActiveRecord::Base
    has_and_belongs_to_many :projects, join_table: "projects_critical_technologies_per_projects"

    def to_s
      name
    end
  end
end
