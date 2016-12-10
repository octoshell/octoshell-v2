module Pack
  class Projectsver < ActiveRecord::Base
  	validates :core_project_id, :version_id, presence: true
  	belongs_to :core_project
  	belongs_to :version
  end
end
