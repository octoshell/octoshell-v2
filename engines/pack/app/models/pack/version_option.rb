module Pack
  class VersionOption < ActiveRecord::Base
  	belongs_to :version
  	validates :name,:value, presence: true
  	validates_uniqueness_of :name,:scope => :version_id
  end
end
