module Pack
  class ApplicationController < ActionController::Base
  	 layout "layouts/application"
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_action do |controller|
    	@extra_css="pack/pack.css"
    end
    
    def per_record
      10
    end
    
    def stale_update_page
      
    end
    def render_paginator(records,partial='table',table_selector='#table_records',
      paginator_selector='#ajax_paginator')
      
      #@records,@partial,@table_selector,@paginator_selector=records,partial,table_selector,paginator_selector
      render "helper_templates/render_paginator",format: :js,locals: {records: records,
       partial: partial, table_selector: table_selector,paginator_selector: paginator_selector }
    end 

    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
  	end
  end
end
