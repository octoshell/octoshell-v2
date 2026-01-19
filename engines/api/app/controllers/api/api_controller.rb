module Api
  class ApiController < ApplicationController

    def api_request
      begin
        auth = request.headers['X-OctoAPI-Auth']
        access_key = AccessKey.where(key: auth).take
        if access_key.nil?
          render plain: t('not_allowed'), status: 404
        else
          req = Export.joins(:access_keys).where(api_access_keys:{id: access_key.id}).where(request: params[:req]).take
          if req.nil?
            render plain: t('not_allowed_explained', req: params[:req], id: access_key.id, key: access_key.key), status: 403
          else
            vars = Hash[req.key_parameters.map{|p| [p.name,(params[p.name]||p.default)]}]
            text = execute_request req.text, vars, req.safe
            render plain: text
          end
        end
      rescue => e
        render plain: t('error', err: e.message), status: 500
      end
    end

    private

    def execute_request text, args, safe=true
      result = nil
      full_text = text.gsub(/%[^% \t]+%/) { |match|
        m = match[1..-2]
        if args[m]
          args[m]
        else
          match
        end
      }
      ActiveRecord::Base.transaction do
        result = eval full_text
        raise ActiveRecord::Rollback if safe
      end
      result
    end
  end
end
