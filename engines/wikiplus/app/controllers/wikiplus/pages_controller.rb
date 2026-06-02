module Wikiplus
  class PagesController < ApplicationController
    def index
      @pages = Page.visible_for(current_user).where(mainpage_id: nil).order(:sortid)
    end

    def show
      @page = nil
      begin
        @page = Page.visible_for(current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
      end
      redirect_to pages_path, notice: t('wikiplus.not_found_page') unless @page
    end

    private
  end
end
