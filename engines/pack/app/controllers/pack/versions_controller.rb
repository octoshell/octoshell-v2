require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
  	def show
  		@options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
        end
      @options_for_select<<[t('user'),"user"] 
  		@version = Version.includes(:version_options,:accesses,clustervers: :core_cluster).order(:id).find(params[:id])
  		@accesses=@version.accesses.user_access(current_user.id)
      if @version.service &&  @accesses.select{|a| a.status=="allowed"} && !may?(:manage, :packages) 
        raise MayMay::Unauthorized
      end
  	end
  end
end
