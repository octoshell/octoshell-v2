# == Schema Information
#
# Table name: jobstat_float_data
#
#  id         :integer          not null, primary key
#  name       :string
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  job_id     :integer
#
# Indexes
#
#  index_jobstat_float_data_on_job_id  (job_id)
#

module Jobstat
  class FloatDatum < ApplicationRecord
  end
end
