require_dependency "cloud_computing/application_controller"

module CloudComputing
  class Admin::ClustersController < Admin::ApplicationController
    def index
      @clusters = Cluster.all
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @clusters.page(params[:page])
                                           .per(params[:per]),
                         total: @clusters.count }
        end
      end
    end

    def show
      @cluster = Cluster.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @cluster }
      end
    end

    def new
      @cluster = Cluster.new
    end

    def create
      @cluster = Cluster.new(cluster_params)
      if @cluster.save
        redirect_to [:admin, @cluster]
      else
        render :new
      end
    end

    def edit
      @cluster = Cluster.find(params[:id])
    end

    def update
      @cluster = Cluster.find(params[:id])
      if @cluster.update(cluster_params)
        redirect_to [:admin, @cluster]
      else
        render :edit
      end
    end

    def destroy
      @cluster = Cluster.find(params[:id])
      @cluster.destroy!
      redirect_to admin_clusters_path
    end

    private

    def cluster_params
      params.require(:cluster).permit(*CloudComputing::Cluster
                                       .locale_columns(:description),
                                      :core_cluster_id)
    end
  end
end
