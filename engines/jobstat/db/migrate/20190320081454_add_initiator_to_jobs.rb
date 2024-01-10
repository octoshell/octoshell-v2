# This migration comes from jobstat (originally 20190320081454)
class AddInitiatorToJobstatJobs < ActiveRecord::Migration[5.2]
  def change
    add_reference :jobstat_jobs, :initiator
  end
end
