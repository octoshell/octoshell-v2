require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper

    def show
      @job = Job.find(params["id"])

      @job_perf = @job.get_performance
      @ranking = @job.get_ranking

      cpu_user = FloatDatum.where(job_id: @job.id, name: "cpu_user").take

      if cpu_user.nil? || cpu_user.value.nil?
        render :show_no_data
      end
    end

    def show_direct
      job = Job.where(drms_job_id: params["drms_job_id"], cluster: params["cluster"]).take
      redirect_to :action => 'show', :id => job.id
    end
  end
end
