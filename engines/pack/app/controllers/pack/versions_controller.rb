require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
  	def show
  		@options_for_select=Core::Project.joins(members: :user).where(core_members:{user_id: current_user.id,owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
        end
      @options_for_select<<[t('user'),"user"] 
  		@version = Version.includes(:version_options,:accesses,clustervers: :core_cluster).order(:id).find(params[:id])
  		@version.user_accesses=@version.accesses.user_access(current_user.id)
      if @version.service &&  @version.user_accesses.select{|a| a.status=="allowed"} && !may?(:manage, :packages) 
        raise MayMay::Unauthorized
      end
  	end

    def index
      
      respond_to do |format|
      format.json do

        @versions = Version.finder(params[:q]).page(params[:page]).per(params[:per]).includes(:package)
        @hash=[]
        @versions.each do |item|
        
        @hash<<{ text: item.name +  "   #{t('Package_name')}: #{item.package.name}", id: item.id }
        end        
        render json: { records: @hash, total: @versions.count }

      
        
      end
      end
    end
  end
end
