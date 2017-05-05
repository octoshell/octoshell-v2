require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
  	def show
  		@options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
        end
        @options_for_select<<[t('user'),"user"] 
  		 @version = Version.includes(:version_options,:accesses,clustervers: :core_cluster).find(params[:id])
  		
  	end
  end
end
