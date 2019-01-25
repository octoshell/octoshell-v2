# == Schema Information
#
# Table name: jobstat_digest_float_data
#
#  id         :integer          not null, primary key
#  name       :string
#  job_id     :integer
#  value      :float
#  time       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Jobstat
  class DigestFloatDatum < ActiveRecord::Base
  end
end
