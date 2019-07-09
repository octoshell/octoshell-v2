#TODO: refactor (may be delete it?)
#
module Jobstat
  class ClusterConfig

    has_paper_trail

    attr_accessor :name, :id, :partitions, :states

    def initialize(name, id)
      @name = name
      @id = id
      @states = []
      @partitions = {}
    end
  end
end
