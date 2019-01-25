# == Schema Information
#
# Table name: jobstat_digest_string_data
#
#  id         :integer          not null, primary key
#  name       :string
#  job_id     :integer
#  value      :string
#  time       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Jobstat
  class DigestStringDatum < ActiveRecord::Base
  end
end
