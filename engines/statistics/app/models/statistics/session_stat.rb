module Statistics
  class SessionStat < ActiveRecord::Base
    KINDS = [ ]

    include StatCollector
    include GraphBuilder
  end
end
