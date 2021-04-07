require_dependency "core/application_controller"

module Core
  class BotLinksApiController < ApplicationController
    def index
      result = params

      case params[:method]
      when 'auth'
        result = BotLinksApiHelper.auth(params)
      when 'topics'
        result = BotLinksApiHelper.topics(params)
      when 'clusters'
        result = BotLinksApiHelper.clusters(params)
      when 'user_projects'
        result = BotLinksApiHelper.user_projects(params)
      when 'user_tickets'
        result = BotLinksApiHelper.user_tickets(params)
      when 'user_jobs'
        result = BotLinksApiHelper.user_jobs(params)
      when 'create_ticket'
        result = BotLinksApiHelper.create_ticket(params)
      end

      render json: result
    end
  end
end
