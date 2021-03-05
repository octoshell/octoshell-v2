module CloudComputing::Admin
  class ApplicationController < CloudComputing::ApplicationController
    before_action :check_abilities
    layout 'layouts/cloud_computing/admin'

    def check_abilities
      authorize! :manage, :cloud
    end
    
    before_action do
      @admin = true
    end

  end
end
