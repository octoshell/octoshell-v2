module Wikiplus
  class Admin::PagesController < Admin::ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    def index
      @pages = Page.where(mainpage_id: nil).order(:sortid)
    end

    def show
      @page = Page.find(params[:id])
    end

    def new
      @images = Image.all
      @page = Page.new
    end

    def create
      @page = Page.new(page_params)
      if @page.save
        redirect_to [:admin, @page]
      else
        render :new
      end
    end

    def newsubpage
      @images = Image.all
      @page = Page.find(params[:id])
    end

    def createsubpage
      @images = Image.all
      #params[:id] =~ /(\d+)-.*/
      parent_page = Page.find(params[:id])
      #logger.warn "parent=#{parent_page} params=#{params.inspect}"
      new_page = Page.new(mainpage: parent_page, name_ru: params[:name_ru], name_en: params[:name_en], content_ru: params[:content_ru], content_en: params[:content_en], sortid: params[:sortid], url: params[:url])
      if new_page.save
        #logger.warn "Saved!"
        @page=new_page
        redirect_to [:admin, @page]
      else
        flash.now[:notice] = "Error: #{new_page.errors.full_messages}"
        logger.warn "Error: #{new_page.errors.full_messages}"
        @page=parent_page
        render 'newsubpage'
      end
    end




    def edit
      @images = Image.all
      @page = Page.find(params[:id])
    end

    def update
      @page = Page.find(params[:id])
      if @page.update(page_params)
        redirect_to [:admin, @page]
      else
        render :edit
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.destroy
      redirect_to admin_pages_path
    end

    private

    def check_abilities
      authorize! :manage, :pages
    end

    def page_params
      params.require(:page).permit(*Page.locale_columns(:name, :content),:sortid, :url, :show_all, :image)
    end
  end
end
