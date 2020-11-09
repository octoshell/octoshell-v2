module CloudComputing
  class Configuration < ApplicationRecord
    translates :name, :description
    belongs_to :cluster, inverse_of: :configurations
    has_many :resources, inverse_of: :configuration
    has_many :requests, inverse_of: :configuration

    accepts_nested_attributes_for :resources, allow_destroy: true
    validates_translated :name, :description, presence: true
    validates :available, :position, numericality: { greater_than_or_equal_to: 0 },
                                     presence: true

     def self.last_position
       order(position: :desc).first&.position || -1
     end

  end
end
