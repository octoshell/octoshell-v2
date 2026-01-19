
module Pack
  class CategoryValuesController < ApplicationController
    def values
      @records = CategoryValue.where(options_category_id: params[:id])
      render json: @records
    end
  end
end
