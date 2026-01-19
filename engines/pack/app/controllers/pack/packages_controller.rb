#require "app/services/pack/pack_search_service"

module Pack
  class PackagesController < ApplicationController
    def index
      @q_form = OpenStruct.new(params[:q] || { clustervers_active_in: '1' })
      search = PackSearch.new(@q_form.to_h, 'packages', current_user.id)
      @packages = search.get_results(search.table_relation.allowed_for_users).page(params[:page]).per(15)
    end

    def json
      @packages = Package.finder(params[:q]).allowed_for_users_with_joins(current_user.id)
      render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count }
    end

    def show
      @options_for_select = []
      @options_for_select_labels = []
      Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).each do |item|
        @options_for_select << item.id
        @options_for_select_labels << t('project') + ' ' + item.title
      end
      @options_for_select << "user"
      @options_for_select_labels << t("user")
      @package = Package.find(params[:id])
      @versions = @package.versions
                          .allowed_for_users
                          .user_access(current_user.id,"LEFT").order(:id)
                          .page(params[:page]).per(6)
                          .includes({ clustervers: :core_cluster }, :package)
                          .distinct
    end

  end
end
