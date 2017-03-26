module Pack
  class VersionOption < ActiveRecord::Base
  	belongs_to :version,inverse_of: :version_options
  	validates :name,:value,:version, presence: true
  	validates_uniqueness_of :name,:scope => :version_id
  end
end
