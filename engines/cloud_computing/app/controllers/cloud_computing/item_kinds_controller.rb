require_dependency "cloud_computing/application_controller"

module CloudComputing
  class ItemKindsController < ApplicationController


    def index
      @item_kinds = ItemKind.order(:lft)
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @item_kinds.page(params[:page])
                                                 .per(params[:per]),
                         total: @item_kinds.count }
        end
      end
    end

    def show
      @item_kind = CloudComputing::ItemKind.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @item_kind }
      end
    end

  end
end
