require_dependency "cloud_computing/application_controller"
module CloudComputing
  class ItemsController < ApplicationController

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
          params[:q] ||= {
            item_kind_and_descendants: ItemKind.virtual_machine_cloud_type.id
          }
          @search = CloudComputing::Item.for_users.search(params[:q])
          @items = @search.result(distinct: true)
                          .order_by_name
                          .page(params[:page])
                          .per(params[:per])
          @positions = Position.with_user_requests(current_user.id)
                               .where(cloud_computing_requests: {status: 'created'})
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

    def edit
      @item = CloudComputing::Item.for_users.find(params[:id])
      @positions = @item.positions.with_user_requests(current_user)
    end

    def update
      @item = CloudComputing::Item.for_users.find(params[:id])
      @positions = @item.assign_positions(current_user, position_params)
      if @positions.reject(&:marked_for_destruction?).all?(&:valid?)
        @positions.each do |pos|
          if pos.marked_for_destruction?
            pos.destroy
          else
            pos.save!
          end
        end
        redirect_to @item, flash: { info: t('.updated_successfully') }
      else
        render :show, flash: { info: t('.errors') }
      end
    end

    def position_params
      # params.require(:item).permit(positions_attributes: %i[amount id _destroy])
      return {} unless params[:item] && params[:item][:positions_attributes]

      params.permit(item: { positions_attributes: %i[amount id _destroy] })[:item][:positions_attributes]

    end
  end
end
