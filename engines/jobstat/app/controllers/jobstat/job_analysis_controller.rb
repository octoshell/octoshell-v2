require_dependency "jobstat/application_controller"

module Jobstat
  class JobAnalysisController < ApplicationController

    def show
      @job = Job.find(params["id"])

      @thresholds_conditions = get_thresholds_conditions(@job)
      @primary_conditions = get_primary_conditions(@job)
      @smart_conditions = get_smart_conditions(@job)

      res = {}
      res = res.merge(@@thresholds_conditions)
      res = res.merge(@@primary_conditions)
      res = res.merge(@@smart_conditions)
      @condition_descriptions = res
    end
  end
end
