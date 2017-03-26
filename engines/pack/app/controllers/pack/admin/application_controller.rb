module Pack
  class Admin::ApplicationController < ApplicationController
  	 
    
    
    
     before_filter :check_abilities
    def check_abilities
      
      authorize! :manage, :packages
    end
  end
end
