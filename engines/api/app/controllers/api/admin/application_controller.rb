module Api::Admin
  class ApplicationController < Api::ApplicationController
    # layout "layouts/api/admin/application"
    protect_from_forgery with: :exception
  end
end
