require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      result = params

      if params[:method] == 'auth'
        result = BotLinksApiHelper.auth(params)
      elsif params[:method] == 'bots'
        result = BotLinksApiHelper.load_bot_links
      end

      render json: result
    end
  end
end
