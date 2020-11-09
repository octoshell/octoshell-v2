require_dependency "cloud_computing/application_controller"

module CloudComputing
  class Admin::ConfigurationsController < Admin::ApplicationController
    def index
      @configurations = CloudComputing::Configuration.order(:position)
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @configurations.page(params[:page])
                                                 .per(params[:per]),
                         total: @configurations.count }
        end
      end
    end

    def show
      @configuration = CloudComputing::Configuration.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @configuration }
      end
    end

    def new
      @configuration = CloudComputing::Configuration.new(position: cur_position)
      fill_resources
    end

    def create
      @configuration = CloudComputing::Configuration.new(configuration_params)
      if @configuration.save
        redirect_to [:admin, @configuration]
      else
        render :new
      end
    end

    def edit
      @configuration = CloudComputing::Configuration.find(params[:id])
      fill_resources
    end

    def update
      @configuration = CloudComputing::Configuration.find(params[:id])
      if @configuration.update(configuration_params)
        redirect_to [:admin, @configuration]
      else
        render :edit
      end
    end

    def destroy
      @configuration = CloudComputing::Configuration.find(params[:id])
      @configuration.destroy!
      redirect_to admin_configurations_path
    end

    private

    def cur_position
      CloudComputing::Configuration.last_position + 1
    end

    def fill_resources
      (CloudComputing::ResourceKind.all -
        @configuration.resources.map(&:resource_kind)).each do |kind|
        r = @configuration.resources.new(resource_kind: kind, new_requests: true)
        r.mark_for_destruction unless @configuration.new_record?
      end
    end

    def configuration_params
      params.require(:configuration).permit(*CloudComputing::Configuration
                                           .locale_columns(:name, :description),
                                          :available, :position, :new_requests,
                                          resources_attributes: %i[id value
                                          resource_kind_id new_requests
                                          _destroy])
    end
  end
end
