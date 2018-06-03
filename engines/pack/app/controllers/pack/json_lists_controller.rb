require_dependency "pack/application_controller"

module Pack
  class JsonListsController < ApplicationController
  	def get_clusters


      
      q=params[:q]
      if q
        @clusters = Core::Cluster.finder(params[:q])
      else
        @clusters = Core::Cluster.order(:id)
      end
      respond_to do |format|
        
        format.json {render json: { records: @clusters.page(params[:page]).per(params[:per]), total: @clusters.count }}
      end
   

  	end

  	
  end
end
