require_dependency "cloud_computing/application_controller"

module CloudComputing
  class ItemKindsController < ApplicationController
    def show
      @item_kind = ItemKind.find(params[:id])
    end
  end
end
