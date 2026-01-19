
module Pack
  class Admin::OptionsCategoriesController < Admin::ApplicationController

    def index
      @records = OptionsCategory.order(:id)
      without_pagination(:records)
      respond_to do |format|
        format.html
      end
    end

    def new
      @option = OptionsCategory.new
    end

    def create
      @option = OptionsCategory.new
      if @option.update(option_params)
        redirect_to admin_options_category_path(@option)
      else
        render :new
      end
    end

    def edit
      @option = OptionsCategory.find(params[:id])
    end

    def show
      @option = OptionsCategory.find(params[:id])
    end

    def update
      @option = OptionsCategory.find(params[:id])
      if @option.update(option_params)
        redirect_to admin_options_category_path(@option)
      else
        render :edit
      end
    end

     def destroy
      @option = OptionsCategory.find(params[:id])
      @option.destroy
      redirect_to admin_options_categories_path
    end

    private

    def option_params
      params.require(:options_category).permit *OptionsCategory.locale_columns(:category),
                                               category_values_attributes: [:id, :_destroy, CategoryValue.locale_columns(:value)]
    end
  end
end
