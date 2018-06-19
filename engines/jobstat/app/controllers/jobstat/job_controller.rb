require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper

    def show
      @job = Job.find(params["id"])

      @job_perf = @job.get_performance
      @ranking = @job.get_ranking

      @thresholds_conditions = @job.get_thresholds_conditions()
      @primary_conditions = @job.get_primary_conditions()
      @smart_conditions = @job.get_smart_conditions()

      res = {}
      res = res.merge(Conditions::THRESHOLDS_CONDITIONS)
      res = res.merge(Conditions::PRIMARY_CONDITIONS)
      res = res.merge(Conditions::SMART_CONDITIONS)
      @condition_descriptions = res

      cpu_user = FloatDatum.where(job_id: @job.id, name: "cpu_user").take
      @no_data = cpu_user.nil? || cpu_user.value.nil?
    end

    def show_direct
      job = Job.where(drms_job_id: params["drms_job_id"], cluster: params["cluster"]).take
      redirect_to :action => 'show', :id => job.id
    end

  end
end
