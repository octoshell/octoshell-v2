require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class AccessesController < CloudComputing::Admin::ApplicationController

    before_action only: %i[show edit_vm update_vm approve deny
      edit_links update_links initial_edit update reinstantiate] do
      @access = CloudComputing::Access.find(params[:id])
    end

    def index
      @search = CloudComputing::Access.search(params[:q])
      @accesses = @search.result(distinct: true)
                         .includes(:user, :allowed_by, :for)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])

    end


    def show
    end

    def edit_vm
    end

    def update_vm
      if @access.update(access_params)
        redirect_to edit_links_admin_access_path(@access)
      else
        render :edit_vm
      end
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

    def approve
      @access.approve!
      redirect_to [:admin, @access]
    end

    def reinstantiate
      @access.instantiate_vm
      redirect_to [:admin, @access]
    end

    def deny
      @access.deny!
      redirect_to [:admin, @access]
    end



    def new
      @access = CloudComputing::Access.new
    end

    def create
      @access = CloudComputing::Access.new(access_params)
      @access.allowed_by ||= current_user
      if @access.save
        redirect_to_edit_vm
      else
        render :new
      end
    end

    def initial_edit; end

    def update
      if @access.update(access_params)
        redirect_to_edit_vm
      else
        render :initial_edit
      end
    end



    def create_from_request
      @access = CloudComputing::Access.new(request_id: params[:request_id])
      @access.allowed_by = current_user
      @access.copy_from_request
      @access.save!
      redirect_to [:admin, @access]
    end



    def edit_extented_info; end

    def update_extended_info

    end

    private

    def redirect_to_edit_vm
      redirect_to edit_vm_admin_access_path(@access)
    end

    def access_params
      params.require(:access)
            .permit(:for_id, :for_type, :user_id, :finish_date,
                    left_positions_attributes:[:id, :amount, :_destroy,
                    :item_id, from_links_attributes: %i[id _destroy from_id
                    amount to_item_id], resource_positions_attributes:
                    %i[id resource_id value],
                    from_positions_attributes: [:id, :to_link_amount, :_destroy,
                      resource_positions_attributes: %i[id resource_id value] ],
                    ])
    end
  end
end
