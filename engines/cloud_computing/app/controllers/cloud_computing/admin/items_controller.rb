require_dependency "cloud_computing/application_controller"

module CloudComputing
  class Admin::ItemsController < Admin::ApplicationController
    def index
      @items = CloudComputing::Item.all
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @items.page(params[:page])
                                                 .per(params[:per]),
                         total: @items.count }
        end
      end
    end

    def show
      @item = CloudComputing::Item.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @item }
      end
    end

    def new
      @item = CloudComputing::Item.new
      fill_resources
    end

    def create
      @item = CloudComputing::Item.new(item_params)
      fill_resources
      if @item.save
        redirect_to [:admin, @item]
      else
        render :new
      end
    end

    def edit
      @item = CloudComputing::Item.find(params[:id])
      fill_resources
    end

    def update
      @item = CloudComputing::Item.find(params[:id])
      fill_resources
      if @item.update(item_params)
        redirect_to [:admin, @item]
      else
        render :edit
      end
    end

    def destroy
      @item = CloudComputing::Item.find(params[:id])
      @item.destroy!
      redirect_to admin_items_path
    end

    private

    # def cur_position
    #   CloudComputing::Item.last_position + 1
    # end

    def fill_resources
      @item.fill_resources
    end

    def item_params
      params.require(:item).permit(*CloudComputing::Item
                                           .locale_columns(:name, :description),
                                          :identity,
                                          :item_kind_id,
                                          :new_requests,
                                          resources_attributes: %i[id value
                                          resource_kind_id min max editable
                                          _destroy])
    end
  end
end
