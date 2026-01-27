# == Schema Information
#
# Table name: jobstat_float_data
#
#  id         :integer          not null, primary key
#  name       :string
#  value      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  job_id     :bigint(8)
#
# Indexes
#
#  index_jobstat_float_data_on_job_id  (job_id)
#

module Jobstat
  class FloatDatum < ApplicationRecord
    def self.versions_enabled
      false
    end

    def self.save_job_perf(job_id, hash)
      where(job_id: job_id).destroy_all
      where(job_id: job_id, name: 'instructions').first_or_create
                                                 .update({ value: hash['avg']['fixed_counter1'] })
      %w[cpu_user gpu_load ipc ib_rcv_data_fs ib_xmit_data_fs ib_rcv_data_mpi ib_xmit_data_mpi
         lustre_read_bytes lustre_write_bytes].each do |ch|
        where(job_id: job_id, name: ch).first_or_create
                                       .update({ value: hash['avg'][ch] })
      end
    end
  end
end
