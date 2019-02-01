# == Schema Information
#
# Table name: jobstat_float_data
#
#  id         :integer          not null, primary key
#  name       :string
#  job_id     :integer
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Jobstat
  class FloatDatum < ActiveRecord::Base
  end
end
