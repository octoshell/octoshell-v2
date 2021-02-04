require_dependency "cloud_computing/application_controller"

module CloudComputing
  class RequestsController < ApplicationController

    before_action do
      authorize! :create, CloudComputing::Request
    end

    before_action only: %i[created_request edit_created_request
                           update_created_request edit_vm update_vm
                           edit_links update_links edit_net] do
      @request = user_requests.find_or_initialize_by(status: 'created')
    end

    before_action only: %i[to_sent cancel edit_vm update_vm] do
      @request = user_requests.find_by_status('created')
    end


    def index
      @search = user_requests.search(params[:q])
      @requests = @search.result(distinct: true)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])

    end

    def edit_created_request

    end

    def update_created_request
      if @request.update(request_params)
        @request.left_items.each do |item|
          item.resource_items.each do |r_i|
            r_i.destroy if r_i.item.template_id != r_i.resource.template_id
          end
        end

        # if @request.items.any?
        #   redirect_to edit_vm_requests_path
        # else
          redirect_to created_request_requests_path, notice: t('.updated_successfully')
        # end
      else
        render :edit_created_request
      end
    end

    def edit_vm

    end

    def update_vm
      if @request.update(request_params)
        redirect_to edit_links_requests_path
      else
        render :edit_vm
      end
    end


    def edit_links

    end

    def edit_net
    end

    def update_links
      if @request.update(request_params)
        redirect_to created_request_requests_path, notice: t('.updated_successfully')
      else
        render :edit_links
      end
    end




    def created_request

    end

    def to_sent
      @request.to_sent!
      redirect_to @request
    end

    def cancel
      @request.cancel!
      redirect_to @request
    end


    def show
      @request = user_requests.find(params[:id])
      if @request.created?
        render :created_request
      else
        render :show
      end
    end

    private

    def user_requests
      Request.where(created_by: current_user)
    end

    def request_params
      params.require(:request).permit(:for_id, :for_type, :comment, :finish_date,
        left_items_attributes:[:id, :amount, :_destroy, :template_id,
          from_links_attributes: [:id, :_destroy, :from_id, :amount, :to_item_id],
          from_items_attributes: [:id, :to_link_amount, :_destroy,
            resource_items_attributes: %i[id resource_id value] ],
          resource_items_attributes: %i[id resource_id value]])
    end
  end
end
