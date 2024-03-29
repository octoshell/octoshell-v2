# == Schema Information
#
# Table name: core_research_areas
#
#  id         :integer          not null, primary key
#  name_en    :string
#  name_ru    :string(255)
#  old_group  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  group_id   :bigint(8)
#
# Indexes
#
#  index_core_research_areas_on_group_id  (group_id)
#

module Core
  class ResearchArea < ApplicationRecord
    has_many :project_research_areas, inverse_of: :research_area
    has_many :projects, through: :project_research_areas, inverse_of: :research_areas
    belongs_to :group, class_name: GroupOfResearchArea.to_s, inverse_of: :research_areas
    translates :name
    validates_translated :name, presence: true
    validates :group, presence: true
    def to_s
      name
    end
  end
end
