module CloudComputing
  class ApplicationController < ::ApplicationController
    before_action :require_login
    before_action :check_abilities

    layout 'layouts/cloud_computing/application'

    def check_abilities
      authorize! :test, :cloud
    end

  end
end
