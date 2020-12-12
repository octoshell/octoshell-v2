require_dependency "cloud_computing/application_controller"
module CloudComputing
  class ItemsController < ApplicationController
    layout false, only: [:simple_show]

    def index
      respond_to do |format|
        format.json do
          @items = Item.for_users.where(item_kind: ItemKind.find(params[:item_kind_id])
                                                           .self_and_descendants)
                       .includes(resources: :resource_kind)
          per = params[:per] || 20
          pages = (@items.count.to_f / per).ceil
          page = (params[:page] || 1).to_i
          page = page > pages ? pages : page

          render json: { data: @items.page(page).per(per), pages: pages, page: page }

        end
        format.html do
          @search = CloudComputing::Item.for_users.search(params[:q])
          @items = @search.result(distinct: true)
                          .order_by_name
                          .page(params[:page])
                          .per(params[:per])
          @positions = Position.with_user_requests(current_user.id)
                               .where(item_id: @items.map(&:id))
                               .group('item_id')
                               .sum('amount')
        end
      end

    end

    def show
      @item = CloudComputing::Item.for_users.find(params[:id])
      @positions = @item.find_or_build_positions_for_user(current_user)
    end

    def simple_show
      @item = CloudComputing::Item.for_users.find(params[:id])
      render :show
    end

    def item_kind
      @items = Item.where(item_kind: @item_kind.self_and_descendants)
      respond_to do |format|
        format.json do
          render json: @item_kinds.map{ |i_k| { id: i_k.id, text: i_k.name } }
        end
      end

    end

    def edit
      @item = CloudComputing::Item.for_users.find(params[:id])
      @positions = @item.positions.with_user_requests(current_user)

    end
    # def

    def update
      @item = CloudComputing::Item.for_users.find(params[:id])
      puts position_params.inspect.red
      # dwadaw
      @positions = @item.assign_positions(current_user, position_params)
      if @positions.all?(&:valid?)
        @positions.each(&:save!)
        redirect_to @item, flash: { info: t('.updated_successfully') }
      else
        @positions.each { |pos|  puts pos.errors.inspect.red }
        render :show, flash: { info: t('.errors') }
      end
    end

    def destroy
      @item = CloudComputing::Item.for_users.find(params[:id])
      @position = @item.find_position_for_user(current_user)
      @position.destroy
      redirect_to @item, flash: { info: t('.destroyed_successfully') }

    end

    def position_params
      # params.require(:item).permit(positions_attributes: %i[amount id _destroy])
      return {} unless params[:item] && params[:item][:positions_attributes]

      params.permit(item: { positions_attributes: %i[amount id _destroy] })[:item][:positions_attributes]

    end
  end
end
