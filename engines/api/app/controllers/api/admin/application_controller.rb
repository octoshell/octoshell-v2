module Api::Admin
  class ApplicationController < Api::ApplicationController
    protect_from_forgery with: :exception
  end
end
