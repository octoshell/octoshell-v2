module Core
  class OrganizationKindsController < ApplicationController
    respond_to :json

    def index
      @kinds = OrganizationKind.finder(params[:q])
      json = {
        records: @kinds.page(params[:page]).per(params[:per]),
        total: @kinds.count
      }
      respond_with(json)
    end
  end
end
