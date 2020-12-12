require_dependency "cloud_computing/application_controller"

module CloudComputing
  class ItemKindsController < ApplicationController
    def show

      @item_kind = ItemKind.find(params[:id])
      @item_kinds = @item_kind.self_and_descendants
      respond_to do |format|
        format.json do
          render json: @item_kinds.map{ |i_k| { id: i_k.id, text: i_k.name } }
        end
      end
    end
  end
end
