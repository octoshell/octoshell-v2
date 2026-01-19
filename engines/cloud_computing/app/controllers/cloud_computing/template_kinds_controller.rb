
module CloudComputing
  class TemplateKindsController < ApplicationController


    def index
      @template_kinds = TemplateKind.order(:lft)
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @template_kinds.page(params[:page])
                                                 .per(params[:per]),
                         total: @template_kinds.count }
        end
      end
    end

    def show
      @template_kind = CloudComputing::TemplateKind.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @template_kind }
      end
    end

  end
end
