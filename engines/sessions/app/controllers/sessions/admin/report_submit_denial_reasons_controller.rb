module Sessions
  class Admin::ReportSubmitDenialReasonsController < Admin::ApplicationController
    def index
      @reasons = ReportSubmitDenialReason.all
    end

    def new
      @reason = ReportSubmitDenialReason.new
    end

    def create
      @reason = ReportSubmitDenialReason.new(report_submit_denial_reason_params)
      if @reason.save!
        redirect_to admin_report_submit_denial_reasons_path
      else
        render :new
      end
    end

    def edit
      @reason = ReportSubmitDenialReason.find(params[:id])
    end

    def update
      @reason = ReportSubmitDenialReason.find(params[:id])
      if @reason.update(report_submit_denial_reason_params)
        redirect_to admin_report_submit_denial_reasons_path
      else
        render :edit
      end
    end

    private

    def report_submit_denial_reason_params
      params.require(:report_submit_denial_reason).permit(:name)
    end
  end
end
