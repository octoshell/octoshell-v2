module Core
  class Admin::QuotaKindsController < Admin::ApplicationController
    def index
      @search = QuotaKind.search(params[:q])
      @quota_kinds = @search.result(distinct: true).page(params[:page])
    end

    def new
      @quota_kind = QuotaKind.new
    end

    def create
      @quota_kind = QuotaKind.new(quota_kind_params)
      if @quota_kind.save
        redirect_to admin_quota_kinds_path
      else
        render :new
      end
    end

    def edit
      @quota_kind = QuotaKind.find(params[:id])
    end

    def update
      @quota_kind = QuotaKind.find(params[:id])
      if @quota_kind.update_attributes(quota_kind_params)
        redirect_to admin_quota_kinds_path
      else
        render :edit
      end
    end

    private

    def quota_kind_params
      params.require(:quota_kind).permit(:name, :measurement)
    end
  end
end
