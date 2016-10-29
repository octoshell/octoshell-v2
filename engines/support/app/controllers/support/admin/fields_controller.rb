module Support
  class Admin::FieldsController < Admin::ApplicationController
    def index
      @search = Field.search(params[:q])
      @fields = @search.result(distinct: true).page(params[:page])
    end

    def show
      @field = Field.find(params[:id])
    end

    def new
      @field = Field.new
    end

    def create
      @field = Field.new(field_params)
      if @field.save
        redirect_to [:admin, @field]
      else
        render :new
      end
    end

    def edit
      @field = Field.find(params[:id])
    end

    def update
      @field = Field.find(params[:id])
      if @field.update(field_params)
        redirect_to [:admin, @field]
      else
        render :edit
      end
    end

    def destroy
      @field = Field.find(params[:id])
      @field.destroy
      redirect_to admin_fields_path
    end

    private

    def field_params
      params.require(:field).permit(:name, :url, :required, :contains_source_code, :hint)
    end
  end
end
