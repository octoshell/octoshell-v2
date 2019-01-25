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

module Jobstat
  class DataType < ActiveRecord::Base
  end
end
