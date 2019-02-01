# == Schema Information
#
# Table name: statistics_session_stats
#
#  id         :integer          not null, primary key
#  kind       :string(255)
#  data       :text
#  created_at :datetime
#  updated_at :datetime
#

module Statistics
  class SessionStat < ActiveRecord::Base
    KINDS = [ ]

    include StatCollector
    include GraphBuilder
  end
end
