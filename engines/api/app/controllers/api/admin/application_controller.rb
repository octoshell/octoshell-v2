module Api
  class Admin::ApplicationController < Api::ApplicationController
    protect_from_forgery with: :exception
  end
end
