require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      render json: params
    end
  end
end
