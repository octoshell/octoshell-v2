# == Schema Information
#
# Table name: core_critical_technologies
#
#  id         :integer          not null, primary key
#  name_ru    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string
#

module Core
  class CriticalTechnology < ActiveRecord::Base
    has_and_belongs_to_many :projects, join_table: "projects_critical_technologies_per_projects"
    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end
  end
end
