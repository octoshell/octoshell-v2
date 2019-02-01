module Core
  class Partition < ActiveRecord::Base
    belongs_to :cluster
  end
end
