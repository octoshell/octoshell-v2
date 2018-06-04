require_dependency "pack/application_controller"
#require "app/services/pack/pack_search_service"

module Pack
  class PackagesController < ApplicationController
    def index
      @q_form=OpenStruct.new(params[:q] || {type:'packages',user_access: current_user.id})
      search=Pack::PackSearch.new(@q_form.to_h,current_user.id)
      @model_table=search.model_table
      if search.model_table=='versions'
        @options_for_select=Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).map do |item|
              [t('project') + ' ' + item.title,item.id]
        end
        @options_for_select<<[t('user'),"user"]
      end


      @records=search.get_results(search.table_relation.allowed_for_users).page(params[:page]).per(15)


      Version.preload_and_to_a(current_user.id,@records)  if @model_table=='versions'





      respond_to do |format|


        format.html{

        } # index.html.erb
        format.js {

            render_paginator(@records,"#{@model_table}_table")
        }
        format.json do
          @packages = Package.finder(params[:q])
          render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count }
        end

      end

    end
    def json
        @packages = Package.finder(params[:q])
        render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count }

    end

    def show
      @projects = Core::Project.joins(members: :user).where(core_members: {user_id: current_user.id,owner: true}).to_a
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
                          .uniq
      Version.preload_and_to_a(current_user.id, @versions)
    end










    private
      def package_params
        params.require(:package).permit(:name, :folder, :cost,:description,:deleted)
      end
      def prop_params
        params.require(:pref).permit(:proj_or_user,:def_date)
      end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
