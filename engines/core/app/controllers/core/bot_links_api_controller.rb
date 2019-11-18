require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      result = params

      if params[:method] == 'auth'
        result = BotLinksApiHelper.auth(params)
      elsif params[:method] == 'user_projects'
        result = BotLinksApiHelper.user_projects(params)
      end

      render json: result
    end
  end
end
