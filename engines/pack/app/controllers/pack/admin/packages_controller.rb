require_dependency "pack/application_controller"

module Pack
  class Admin::PackagesController < Admin::ApplicationController
    def index
      respond_to do |format|
        format.html{
          @q_form = OpenStruct.new(params[:q])
          search = PackSearch.new(@q_form.to_h, 'packages')
          @packages = search.get_results(nil).page(params[:page]).per(15)
        } # index.html.erb
        format.json do
          @packages = Package.finder(params[:q]).allowed_for_users_with_joins(current_user.id)
          render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count }
        end
      end
    end

    def show
      @package = Package.find(params[:id])
      @versions = @package.versions.page(params[:page]).per(@per).includes(clustervers: :core_cluster)
    end

    def new
      @package = Package.new
    end

    def create
      @package = Package.new(package_params)
      if @package.save
        redirect_to admin_package_path(@package.id)
      else
        render :new
      end
    end

    def edit
      @package = Package.find(params[:id])
    end

    def update
      @package = Package.find(params[:id])
      if @package.update(package_params)
        redirect_to admin_package_path(@package.id)
      else
        render :edit
      end
    end

    def destroy
      @package = Package.find(params[:id])
      @package.destroy
      redirect_to admin_packages_path
    end

    private

    def package_params
      params.require(:package).permit(:name, :description, :deleted, :lock_version)
    end

    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
