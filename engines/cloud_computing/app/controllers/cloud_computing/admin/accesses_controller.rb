module CloudComputing::Admin
  class AccessesController < CloudComputing::Admin::ApplicationController

    before_action only: %i[show finish approve deny
      edit update reinstantiate prepare_to_deny] do
      @access = CloudComputing::Access.find(params[:id])
    end

    def index
      @search = CloudComputing::Access.ransack(params[:q])
      @accesses = @search.result(distinct: true)
                         .includes(:user, :allowed_by, :for)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])

    end


    def show
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

    def finish
      @access.finish!
      redirect_to [:admin, @access]
    end

    def prepare_to_deny
      @access.prepare_to_deny!
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


    def update
      if @access.update(access_params)
        redirect_to [:admin, @access]
      else
        render :edit
      end
    end



    def create_from_request
      @request = CloudComputing::Request.find(params[:request_id])
      @access = CloudComputing::Access.approved.where(for: @request.for).first
      unless @access
        @access = CloudComputing::Access.new
        @access.allowed_by = current_user
      end
      @access.copy_from_request(@request)
    end

    def save_from_request
      if params[:access_id]
        @access = CloudComputing::Access.where(id: params[:access_id]).first
      end
      @access ||= CloudComputing::Access.new
      @access.allowed_by ||= current_user

      if @access.update(access_params)
        CloudComputing::Request.find(params[:request_id]).approve!
        redirect_to [:admin, @access]
      else
        render 'create_from_request'
      end
    end


    private

    def redirect_to_edit_vm
      redirect_to edit_vm_admin_access_path(@access)
    end

    def access_params

      left_items_attributes = [:id, :amount, :_destroy, :template_id, :item_id,
        from_links_attributes: [:id, :_destroy, :from_id, :amount, :to_item_id],
        from_items_attributes: [:id, :to_link_amount, :_destroy,
          resource_items_attributes: %i[id resource_id value] ],
        resource_items_attributes: %i[id resource_id value]]

      params.require(:access)
            .permit(:for_id, :for_type, :user_id, :finish_date,
                    old_left_items_attributes: left_items_attributes,
                    new_left_items_attributes: left_items_attributes)
    end
  end
end
