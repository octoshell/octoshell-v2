module Core
  class Admin::ClustersController < Admin::ApplicationController
    def index
      @clusters = Cluster.order(:id)
    end

    def show
      @cluster = Cluster.find(params[:id])
    end

    def new
      @cluster = Cluster.new
    end

    def create
      @cluster = Cluster.new(cluster_params)
      if @cluster.save!
        redirect_to [:admin, @cluster], notice: t("flash.cluster_created")
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
        redirect_to [:admin, @cluster], notice: t("flash.cluster_updated")
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
      params.require(:cluster).permit(:name, :host, :admin_login,
                                      :available_for_work,
                                      quotas_attributes: [:id, :quota_kind_id,
                                                          :value, :_destroy])
    end
  end
end
