module Pack
  class Clusterver < ActiveRecord::Base

  	validates :cluster_id, :version_id, presence: true
  	belongs_to :cluster
  	belongs_to :version
  end
end
