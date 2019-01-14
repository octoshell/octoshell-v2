require_dependency "pack/application_controller"

module Pack
  class DocsController < ApplicationController
    def show
      render "#{params[:page]}"
    end

  end
end
