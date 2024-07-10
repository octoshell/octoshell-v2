#Schema Information
#
# Table name: core_critical_technologies
#
#  id         :integer     
#  name_ru    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string
#

module Core
  class CriticalTechnology < ApplicationRecord
    has_many :project_critical_technologies, inverse_of: :critical_technology
    has_many :projects, through: :project_critical_technologies, inverse_of: :critical_technologies

    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end
  end
end
