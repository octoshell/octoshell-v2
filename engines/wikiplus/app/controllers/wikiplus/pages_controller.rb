require_dependency "wikiplus/application_controller"

module Wikiplus
  class PagesController < ApplicationController

    def index
      @pages = Page.where(mainpage_id: nil).order(:sortid)
    end

    def show
      @page = Page.find(params[:id])
    end

    private

  end
end
