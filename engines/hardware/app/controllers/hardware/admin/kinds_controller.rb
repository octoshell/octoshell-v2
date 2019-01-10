module Hardware
  class Admin::KindsController < Admin::ApplicationController
    def index
      @search = Kind.search(params[:q])
      @kinds = @search.result(distinct: true).page(params[:page])
    end

    def states
      @states = Kind.find(params[:kind_id]).states
      render json: @states
    end

    def index_json
      json = Kind.all.map do |k|
        puts k.states.inspect
        k.attributes.merge(states: k.states.map { |s| s.attributes.merge(transitions_to: s.to_states.map(&:attributes)) } )
      end
      render json: json
    end


    def show
      @kind = Kind.find(params[:id])
    end

    def new
      @kind = Kind.new
    end

    def create
      @kind = Kind.new(kind_params)
      if @kind.save
        redirect_to [:admin, @kind]
      else
        render :new
      end
    end

    def edit
      @kind = Kind.find(params[:id])
    end

    def update
      @kind = Kind.find(params[:id])
      if @kind.update(kind_params)
        redirect_to [:admin, @kind]
      else
        render :edit
      end
    end

    def destroy
      @kind = Kind.find(params[:id])
      unless @kind.destroy
        flash[:error] = @kind.errors.full_messages
        redirect_to [:admin, @kind]
        return
      end
      redirect_to admin_kinds_path
    end

    private

    def kind_params
      params.require(:kind).permit(*Kind.locale_columns(:name, :description))
    end
  end
end
