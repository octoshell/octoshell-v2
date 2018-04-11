require_dependency 'comments/application_controller'

module Comments
  class AttachedController < ApplicationController
    def index
      get_model
    end
    def create

    end
  end
end
