require_dependency "cloud_computing/application_controller"

module CloudComputing
  class ItemsController < ApplicationController

    def index
      @search = CloudComputing::Item.for_users.search(params[:q])
      @items = @search.result(distinct: true)
                      .order_by_name
                      .page(params[:page])
                      .per(params[:per])
      @positions = Position.with_user_requests(current_user.id)
                           .where(item_id: @items.map(&:id))
                           .group('item_id')
                           .count('id')
                      # puts @positions.inspect.red

                      # scope :joins_requests, -> { joins('INNER JOIN cloud_computing_requests AS c_r ON c_r.id = cloud_computing_positions.holder_id AND
                      #    cloud_computing_positions.holder_type=\'CloudComputing::Request\' ') }

    end

    def show
      @item = CloudComputing::Item.for_users.find(params[:id])
      puts @item.all_conditions.to_sql.red
      # @positions = @item.find_or_build_for_user(current_user)
    end

    def edit
      @item = CloudComputing::Item.for_users.find(params[:id])
      @positions = @item.positions.with_user_requests(current_user)

    end
    # def

    def update
      @item = CloudComputing::Item.for_users.find(params[:id])
      @position = @item.update_or_create_position(current_user, position_params)
      if @position.save
        redirect_to @item, flash: { info: t('.updated_successfully') }
      else
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
      params.require(:position).permit(:amount,
                                          resources_attributes: %i[id value
                                          resource_kind_id new_requests
                                          _destroy])
    end
  end
end
