require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      result = params

      if %q[auth topics clusters user_projects user_tickets user_jobs create_ticket].include? params[:method]
        result = BotLinksApiHelper.send(params[:method], params)
      end
      render json: result
    end
  end
end
