require_dependency "jobstat/application_controller"

module Jobstat
  class JobController < ApplicationController
    include JobHelper

    def show
      @job = Job.find(params["id"])
      @job_perf = @job.get_performance
      @ranking = @job.get_ranking
    end
  end
end
