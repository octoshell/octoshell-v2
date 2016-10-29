module Wiki
  class PagesController < ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    def index
      @pages = Page.order(:name)
    end

    def show
      @page = Page.find(params[:id])
    end

    def new
      @page = Page.new
    end

    def create
      @page = Page.new(page_params)
      if @page.save
        redirect_to @page
      else
        render :new
      end
    end

    def edit
      @page = Page.find(params[:id])
    end

    def update
      @page = Page.find(params[:id])
      if @page.update(page_params)
        redirect_to @page
      else
        render :edit
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.destroy
      redirect_to pages_path
    end

    private

    def check_abilities
      authorize! :manage, :pages
    end

    def page_params
      params.require(:page).permit(:name, :content, :url, :show_all)
    end
  end
end
