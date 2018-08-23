require_dependency "pack/application_controller"

module Pack
  class Admin::VersionsController < Admin::ApplicationController
    before_action :pack_init, except: [:index]

    def index
      respond_to do |format|
        format.html do
          @q_form = OpenStruct.new(params[:q])
          search = PackSearch.new(@q_form.to_h, 'versions')
          @versions = search.get_results(nil)
          without_pagination(:versions)
        end
        format.json do
          @versions = Version.finder(params[:q]).page(params[:page]).per(params[:per]).includes(:package)
          @hash = []
          @versions.each do |item|
            @hash << { text: item.name + "   #{t('Package_name')}: #{item.package.name}", id: item.id }
          end
          render json: { records: @hash, total: @versions.count }
        end
      end
    end

    def new
      @version = Version.new
      @version.build_clustervers
    end

    def create
      @version = Version.new
      @version.package = @package
      @version.vers_update(params)
      if @version.save
        redirect_to admin_package_version_path(@package, @version)
      else
        render :new
      end
    end

    def edit
      @version = Version.includes(clustervers: :core_cluster).find(params[:id])
      @version.build_clustervers
    end

    def update
      @version = Version.find(params[:id])
      @version.vers_update params
      @stale_message = t("stale_message") if @version.changes["lock_col"]
      if @version.save
        redirect_to admin_package_version_path(@package, @version)
      else
        render :edit
      end

    end

    def show
      @version = Version.includes(:version_options,clustervers: :core_cluster).find(params[:id])
      render 'pack/versions/show'
    end

    def destroy
      @version = Version.find(params[:id])
      @version.destroy
      redirect_to admin_package_path(@package)
    end

    private

    def pack_init
     @package = Package.find(params[:package_id]) if params[:package_id]
     @categories = OptionsCategory.all
    end
  end
end
