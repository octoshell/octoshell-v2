require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      result = params

      if params[:method] == 'auth'
        result = BotLinksApiHelper.auth(params)
      elsif params[:method] == 'topics'
        result = BotLinksApiHelper.topics(params)
      elsif params[:method] == 'clusters'
        result = BotLinksApiHelper.clusters(params)
      elsif params[:method] == 'user_projects'
        result = BotLinksApiHelper.user_projects(params)
      elsif params[:method] == 'user_tickets'
        result = BotLinksApiHelper.user_tickets(params)
      elsif params[:method] == 'create_ticket'
        result = BotLinksApiHelper.create_ticket(params)
      elsif params[:method] == 'notify'
        BotLinksApiHelper.notify(params)
      end

      render json: result
    end
  end
end
