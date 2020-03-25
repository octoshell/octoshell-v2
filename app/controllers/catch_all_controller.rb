class CatchAllController < ApplicationController
  protect_from_forgery except: :index
  def index
    logger.warn "Faked #{params.inspect}"
    case params[:ext]
    when 'js'
      render plain: "\n", content_type: 'text/javascript'
    when 'css'
      render plain: "\n", content_type: 'text/css'
    else
      render plain: 'Ooops! Page not found!', status: :not_found
    end
  end
end
