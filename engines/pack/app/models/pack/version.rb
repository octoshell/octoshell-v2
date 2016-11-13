module Pack
  class Version < ActiveRecord::Base
  	validates :name, :description, presence: true
  	belongs_to :package
  end
end
