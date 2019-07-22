#require_dependency "wikiplus/application_controller"
module Wikiplus
  class Admin::ApplicationController < ::Admin::ApplicationController
    before_filter :authorize_admins

    def authorize_admins
      authorize!(:manage, :wikiplus)
    end  	
  end
end
