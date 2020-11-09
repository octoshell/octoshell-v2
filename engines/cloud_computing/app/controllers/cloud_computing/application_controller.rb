module CloudComputing
  class ApplicationController < ::ApplicationController
    before_action :require_login
    layout 'layouts/cloud_computing/application'
  end
end
