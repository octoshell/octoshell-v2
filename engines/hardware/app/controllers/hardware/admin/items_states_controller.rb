module Hardware
  class Admin::ItemsStatesController < Admin::ApplicationController

    def index
      @search = ItemsState.ransack(params[:q] || { created_at_gt: session[:hardware_max_date] })
      @items_states = @search.result(distinct: true).includes(:state, item: :kind)
                      .page(params[:page])
      without_pagination(:items_states)
    end
  end
end
