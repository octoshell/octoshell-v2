# == Schema Information
#
# Table name: jobstat_string_data
#
#  id         :integer          not null, primary key
#  name       :string
#  job_id     :integer
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Jobstat
  class StringDatum < ActiveRecord::Base
  end
end
