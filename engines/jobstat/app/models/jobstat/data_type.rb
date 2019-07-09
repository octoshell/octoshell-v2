# == Schema Information
#
# Table name: jobstat_data_types
#
#  id         :integer          not null, primary key
#  name       :string
#  type       :string(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jobstat_data_types_on_name  (name)
#

module Jobstat
  class DataType < ActiveRecord::Base

    has_paper_trail

  end
end
