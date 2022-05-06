# == Schema Information
#
# Table name: jobstat_string_data
#
#  id         :integer          not null, primary key
#  name       :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  job_id     :bigint(8)
#
# Indexes
#
#  index_jobstat_string_data_on_job_id  (job_id)
#

module Jobstat
  class StringDatum < ApplicationRecord
    def self.versions_enabled
      false
    end
  end
end
