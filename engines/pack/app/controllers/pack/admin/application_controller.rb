module Pack
  class Admin::ApplicationController < ApplicationController
  	 
    
    
    layout "layouts/pack/admin"

     before_filter :check_abilities
    def check_abilities
      
      authorize! :manage, :packages
    end
  end
end
