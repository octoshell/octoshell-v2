
module Core
  class BotLinksApiController < ApplicationController
    skip_before_action :require_login
    def index
      result = params

      if %q[auth topics clusters user_projects user_tickets user_jobs create_ticket].include? params[:method].to_s
        result = BotLinksApiHelper.send(params[:method], params)
      end
      render json: result
    end
  end
end
