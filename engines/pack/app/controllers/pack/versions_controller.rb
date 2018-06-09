require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
    def show
      @options_for_select = []
      @options_for_select_labels = []
      Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).each do |item|
        @options_for_select << item.id
        @options_for_select_labels << t('project') + ' ' + item.title
      end
      @options_for_select << "user"
      @options_for_select_labels << t("user")
      @version = Version.includes(:version_options,:accesses,clustervers: :core_cluster).order(:id).find(params[:id])
      @versions = [@version]
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
