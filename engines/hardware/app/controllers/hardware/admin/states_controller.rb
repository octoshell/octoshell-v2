module Hardware
  class Admin::StatesController < Admin::ApplicationController
    def show
      @state = State.find(params[:id])
    end

    def states
      @states = Kind.find(params[:kind_id]).states
      render json: @states
    end

    def new
      @state = State.new(kind_id: params[:kind_id])
    end

    def create
      @state = State.new(state_params)
      if @state.save
        redirect_to [:admin, @state.kind, @state]
      else
        render :new
      end
    end

    def edit
      @state = State.find(params[:id])
    end

    def update
      @state = State.find(params[:id])
      if @state.update_attributes(state_params)
        @state.save
        redirect_to [:admin, @state.kind, @state]
      else
        render :edit
      end
    end

    def destroy
      @state = State.find(params[:id])
      unless @state.destroy
        flash :error, @state.errors.full_messages
        redirect_to [:admin, @state.kind, @state]
        return
      end
      redirect_to admin_kind_path(@state.kind)
    end


    private

    def state_params
      params.require(:state).permit(*State.locale_columns(:name, :description),:kind_id,:lock_version, from_state_ids: [], to_state_ids: [])
    end
  end
end
