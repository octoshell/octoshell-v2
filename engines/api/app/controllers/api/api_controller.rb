require_dependency "api/application_controller"

module Api
  class ApiController < ApplicationController

    def api_request
      begin
        auth = request.headers['X-OctoAPI-Auth']
        access_key = AccessKey.where(key: auth).take
        if access_key.nil?
          render plain: "Whoops! You cannot make such requests.\n", status: 404
        else
          req = Export.joins(:access_keys).where(api_access_keys:{id: access_key.id}).where(title: params[:req]).take
          if req.nil?
            render plain: "Request '#{params[:req]}' for ability #{access_key.id}(#{access_key.key}) is not allowed.\n", status: 403
          else
            text = nil
            ActiveRecord::Base.transaction do
              text = eval req.text
              raise ActiveRecord::Rollback
            end
            render plain: text
          end
        end
      rescue => e
        render plain: "Auch! Got error: #{e.message}\n", status: 500
      end
    end
  end
end
