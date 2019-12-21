module Wikiplus
  class Admin::PagesController < Admin::ApplicationController
    before_action :check_abilities, except: [:index, :show]

    def index
      @pages = Page.where(mainpage_id: nil).order(:sortid)
      @list = []
      @pages.each{|p|
        add_to_list_page p, 1
      }
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
      @page.sortid = 1
      if @page.save
        redirect_to [:admin, @page]
      else
        logger.warn @page.errors
        render :new
      end
    end

    def newsubpage
      @images = Image.all
      @page = Page.new(mainpage_id: params[:id])
      render :new
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
        #@page=parent_page
        redirect_to [:admin, :index]
      end
    end

    CH_STR_REGEXP = Regexp.new('page\[(\d+)\]=(\S+)')

    def change_structure
      result = nil
      prio = 0
      items = params[:relations].split('&')
      logger.warn "items: #{items.inspect}"
      items.each{|item|
        prio += 1
        item =~ CH_STR_REGEXP
        page_id = $1.to_i
        parent_id = $2=='null' ? nil : $2.to_i
        begin
          page = Page.find(page_id)
          page.mainpage_id = parent_id
          page.sortid = prio
          page.save!
        rescue => e
          logger.warn "Error: #{e.message}"
          result ||= ''
          result += "Error: #{e.message}\n"
        end
      }
      render text: result ? result : 'ok'
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

    def add_to_list_page p, level
      @list << [p.id,level]
      if p.subpages.size>0
        p.subpages.order(:sortid).each{|subpage|
          add_to_list_page subpage, level+1
        }
      end
    end

    def page_params
      params.require(:page).permit(*Page.locale_columns(:name, :content),:sortid, :mainpage_id, :url, :show_all, :image)
    end
  end
end
