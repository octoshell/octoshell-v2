module CloudComputing
  class Cluster < ApplicationRecord
    translates :description
    belongs_to :core_cluster, class_name: 'Core::Cluster'
    has_many :configurations, inverse_of: :cluster

    validates_translated :description, presence: true
    validates :core_cluster, presence: true, uniqueness: true
  end
end
