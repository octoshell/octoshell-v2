require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
    def show
      @version = Version.includes(:version_options,:accesses,clustervers: :core_cluster).order(:id).find(params[:id])
      @versions = [@version]
      if @version.service &&  @version.user_accesses.select{|a| a.status=="allowed"} && !may?(:manage, :packages)
        raise MayMay::Unauthorized
      end
      @options_for_select = []
      @options_for_select_labels = []
      Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).each do |item|
        @options_for_select << item.id
        @options_for_select_labels << t('project') + ' ' + item.title
      end
      @options_for_select << "user"
      @options_for_select_labels << t("user")
    end

    def index
      respond_to do |format|
        format.html do
          @options_for_select = []
          @options_for_select_labels = []
          Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).each do |item|
            @options_for_select << item.id
            @options_for_select_labels << t('project') + ' ' + item.title
          end
          @options_for_select << "user"
          @options_for_select_labels << t("user")
          @q_form = OpenStruct.new(params[:q] || { user_access: current_user.id,
                                                   id_in: nil,
                                                   clustervers_active_in: '1' })
          search = PackSearch.new(@q_form.to_h, 'versions', current_user.id)
          @versions = search.get_results(search.table_relation.allowed_for_users).page(params[:page]).per(15)
        end

        format.json do
          @versions = Version.finder(params[:q]).page(params[:page]).per(params[:per]).includes(:package)
                                                .allowed_for_users
                                                .user_access(current_user.id,"LEFT")
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
