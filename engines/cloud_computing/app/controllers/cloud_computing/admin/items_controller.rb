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
      (CloudComputing::ResourceKind.all -
        @item.resources.map(&:resource_kind)).each do |kind|
        r = @item.resources.new(resource_kind: kind, new_requests: true)
        r.mark_for_destruction unless @item.new_record?
      end
    end

    def item_params
      params.require(:item).permit(*CloudComputing::Item
                                           .locale_columns(:name, :description),
                                          :available, :max_count, :new_requests,
                                          :item_kind_id, :cluster_id,
                                          resources_attributes: %i[id value
                                          resource_kind_id new_requests
                                          _destroy])
    end
  end
end
