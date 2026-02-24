module Core
  class Admin::ClustersController < Admin::ApplicationController
    before_action :octo_authorize!
    def index
      # @clusters = Cluster.order(:id)
      q = params[:q]
      @clusters = if q
                    Cluster.finder(params[:q])
                  else
                    Cluster.order(:id)
                  end
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @clusters.page(params[:page]).per(params[:per]), total: @clusters.count }
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
        redirect_to [:admin, @cluster], notice: t('flash.cluster_created')
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
        redirect_to [:admin, @cluster], notice: t('flash.cluster_updated')
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
                                      :available_for_work, :description,
                                      *Core::Cluster.locale_columns(:name),
                                      partitions_attributes: %i[id _destroy
                                                                name resources max_submitted_jobs max_running_jobs],
                                      quotas_attributes: %i[id quota_kind_id
                                                            value _destroy])
    end
  end
end
