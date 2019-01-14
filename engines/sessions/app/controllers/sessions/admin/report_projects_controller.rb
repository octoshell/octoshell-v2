module Sessions
  class Admin::ReportProjectsController < Admin::ApplicationController
    before_filter { authorize! :manage, :reports }

    def update
      @report = get_report(params[:report_id])
      project = @report.projects.find(params[:id])
      if @report.assessing? && project.update_attributes(params[:report_project], as: :admin)
        redirect_to [:admin, @report]
      else
        redirect_to [:admin, @report], alert: project.errors.full_messages.to_sentence
      end
    end
  end
end
