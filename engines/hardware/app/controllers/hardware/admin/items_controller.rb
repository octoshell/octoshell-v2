module Hardware
  class Admin::ItemsController < Admin::ApplicationController

    def index
      @search = Item.search(params_q)
      @items = @search.result(distinct: true)
                      .page(params[:page])
                      .preload(:kind)
                      .left_joins(:items_states)
                      .after_or(session[:hardware_max_date])
      name_column = State.current_locale_column(:name)
      @states = {}
      states_rec = Item.where(id: @items.ids).current_state_date
      .joins("INNER JOIN hardware_states AS s on s.id = i_s.state_id ")
      .select("hardware_items.id, s.#{name_column} AS name, s.id AS s_id").after(session[:hardware_max_date]).group('s.id')
      states_rec.each{ |i| @states[i[:id]]= [i[:s_id],i[:name]]  }
      without_pagination(:items)
    end

    def update_max_date
      if params[:hardware_max_date].present? && params[:commit] == t('actions.save')
        session[:hardware_max_date] = params[:hardware_max_date]
      else
        session.delete(:hardware_max_date)
      end
      redirect_to :back
    end

    def show
      @item = Item.find(params[:id])
    end

    def new
      @item = Item.new(kind_id: params[:kind_id])
    end

    def create
      @item = Item.new(item_params)
      if @item.save
        redirect_to [:admin, @item]
      else
        render :new
      end
    end

    def edit
      @item = Item.find(params[:id])
    end

    def update
      @item = Item.find(params[:id])
      if @item.update(item_params)
        last_items_state_unpermitted_params = params[:item].delete(:last_items_state)
        if last_items_state_unpermitted_params
          last_items_state_params = last_items_state_unpermitted_params.permit!
          @item.last_items_state.update! last_items_state_params
        end
        redirect_to [:admin, @item]
      else
        render :edit
      end
    end

    def update_state
      @item = Item.find(params[:item_id])
      if params[:items_states_count].to_i != @item.items_states.count
        flash[:error] = t('.stale')
      else
        @state = State.find_by!(State.current_locale_column(:name) => params[:commit])
        items_state_params = params.require(:items_state).permit(:reason_ru, :reason_en, :description_ru, :description_en)
        @items_state = @item.items_states.new(items_state_params)
        @items_state.state = @state
        @items_state.save!
      end
      redirect_to [:admin, @item]

    end


    def destroy
      @item = Item.find(params[:id])
      @item.destroy
      redirect_to [:admin, @item]
    end

    private

    def params_q
      params[:q] || { only_deleted: false }
    end
    def item_params
      params.require(:item).permit(*Item.locale_columns(:name, :description), :kind_id)
    end
  end
end
