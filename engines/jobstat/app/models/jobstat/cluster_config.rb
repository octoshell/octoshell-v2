module Jobstat
  class ClusterConfig
    attr_accessor :name, :id, :partitions, :states

    def initialize(name, id)
      @name = name
      @id = id
      @states = []
      @partitions = {}
    end
  end
end
