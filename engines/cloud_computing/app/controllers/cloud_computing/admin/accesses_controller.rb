require_dependency "cloud_computing/application_controller"

module CloudComputing
  class Admin::AccessesController < Admin::ApplicationController

    before_action only: %i[show edit_links update_links pend cancel edit update] do
      @access = CloudComputing::Access.find(params[:id])
    end

    def index
      @search = CloudComputing::Access.search(params[:q])
      @accesses = @search.result(distinct: true)
                         .includes(:user, :allowed_by, :for)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])

    end


    def show
    end

    def edit_links
    end

    def update_links
      if @access.update(access_params)
        redirect_to [:admin, @access]
      else
        render :edit_links
      end
    end

    def pend
      @access.pend!
      redirect_to [:admin, @access]
    end

    def cancel
      @access.cancel!
      redirect_to [:admin, @access]
    end



    def new
      @access = CloudComputing::Access.new
    end

    def create
      @access = CloudComputing::Access.new(access_params)
      @access.allowed_by ||= current_user
      if @access.save
        redirect_to [:admin, @access]
      else
        render :new
      end
    end

    def edit; end

    def create_from_request
      @access = CloudComputing::Access.new(request_id: params[:request_id])
      @access.allowed_by = current_user
      @access.copy_from_request
      @access.save!
      redirect_to [:admin, @access]
    end

    def update
      if @access.update(access_params)
        redirect_to [:admin, @access]
      else
        render :edit
      end
    end

    private

    def access_params
      params.require(:access)
            .permit(:for_id, :for_type, :user_id, :finish_date,
                    left_positions_attributes:[:id, :amount, :_destroy,
                    :item_id, from_links_attributes: %i[id _destroy from_id
                    amount to_item_id]])
    end
  end
end
