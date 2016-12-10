module Pack
  class Userver < ActiveRecord::Base
  	validates :user_id, :version_id, presence: true
  	belongs_to :user
  	belongs_to :version
  end
end
