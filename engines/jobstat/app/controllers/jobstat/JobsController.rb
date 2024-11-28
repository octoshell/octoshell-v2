class JobsController < ApplicationController
  def index
    @states_options = {
      "ACTIVE" => "Active",
      "INACTIVE" => "Inactive",
      "PENDING" => "Pending",
      "ALL" => "All"
    }
    
    @params = params[:filter] || {}
    
    @q = Job.ransack(params[:q])
    
    @jobs = @q.result(distinct: true)
  end
end