module Comments
  class Admin::ContextsController < Admin::ApplicationController
    def index
      @contexts = Context.all
    end

    def new
      @context = Context.new
    end

    def create
      @context = Context.new(context_params)
      if @context.save
        redirect_to admin_contexts_path
      else
        render :new
      end
    end

    def edit
      @context = Context.find(params[:id])
    end

    def update
      @context = Context.find(params[:id])
      if @context.update context_params
        redirect_to admin_contexts_path
      else
        render :edit
      end
    end

    def destroy
      @context = Context.find(params[:id])
      @context.destroy
      redirect_to admin_contexts_path
    end

    private

    def context_params
      params.require(:context).permit(:name)
    end
  end
end
