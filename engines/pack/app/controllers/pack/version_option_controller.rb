require_dependency "pack/application_controller"

module Pack
  class VersionOptionController < ApplicationController
  	def index

  		
  		 @options=VersionOption.page(params[:page]).per(2)
  	end
  end
end
