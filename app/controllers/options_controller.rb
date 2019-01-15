require_dependency "pack/application_controller"

class OptionsController < ApplicationController

  def values
    @records = CategoryValue.where(options_category_id: params[:id])
    render json: @records
  end

  def categories
    @options = OptionsCategory.finder(params[:q]).page(params[:page]).per(params[:per])

    render json: { records: @options,
                   total: @options.count }
  end
end
