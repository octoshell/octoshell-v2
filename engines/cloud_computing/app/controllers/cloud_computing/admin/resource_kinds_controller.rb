module CloudComputing::Admin
  class ResourceKindsController < CloudComputing::Admin::ApplicationController
    def index
      @resource_kinds = CloudComputing::ResourceKind.all
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @resource_kinds.page(params[:page])
                                           .per(params[:per]),
                         total: @resource_kinds.count }
        end
      end
    end

    def show
      @resource_kind = CloudComputing::ResourceKind.find(params[:id])
      respond_to do |format|
        format.html do
          render 'cloud_computing/resource_kinds/show'
        end
        format.json { render json: @resource_kind }
      end
    end

    def new
      @resource_kind = CloudComputing::ResourceKind.new
    end

    def create
      @resource_kind = CloudComputing::ResourceKind.new(resource_kind_params)
      if @resource_kind.save
        redirect_to [:admin, @resource_kind]
      else
        render :new
      end
    end

    def edit
      @resource_kind = CloudComputing::ResourceKind.find(params[:id])
    end

    def update
      @resource_kind = CloudComputing::ResourceKind.find(params[:id])
      if @resource_kind.update(resource_kind_params)
        redirect_to [:admin, @resource_kind]
      else
        render :edit
      end
    end

    def destroy
      @resource_kind = CloudComputing::ResourceKind.find(params[:id])
      @resource_kind.destroy!
      redirect_to admin_resource_kinds_path
    end

    private

    def resource_kind_params
      params.require(:resource_kind).permit(*CloudComputing::ResourceKind
                                       .locale_columns(:name, :description,
                                                       :measurement, :help),
                                        :template_kind_id, :identity, :content_type)
    end

  end
end
