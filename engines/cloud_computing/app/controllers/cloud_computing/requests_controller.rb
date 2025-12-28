module CloudComputing
  class RequestsController < ApplicationController

    before_action do
      authorize! :create, CloudComputing::Request
    end

    before_action only: %i[created_request edit_created_request
                           update_created_request edit_vm update_vm
                           edit_links update_links edit_net add_item_from_access] do
      @request = user_requests.find_or_initialize_by(status: 'created')
    end

    before_action only: %i[to_sent cancel edit_vm update_vm] do
      @request = user_requests.find_by_status('created')
    end

    def add_item_from_access
      @item = CloudComputing::Item.find(params[:item_id])

      if @item.item_in_request
        redirect_back fallback_location: @item.holder, flash: flash
        return
      end

      @new_item = @request.left_items.new(item_in_access: @item,
                                          template: @item.template)
      @item.resource_items.each do |resource_item|
        attrs = resource_item.attributes.slice('value', 'resource_id')
        @new_item.resource_items << CloudComputing::ResourceItem.new(attrs)
      end
      if @new_item.save
        flash = {
          notice: t('.added')
        }
      else
        flash = {
          error: @new_item.errors.to_hash
        }
      end
      redirect_back fallback_location: @item.holder, flash: flash

    end


    def index
      @search = user_requests.ransack(params[:q])
      @requests = @search.result(distinct: true)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])

    end

    def edit_created_request
      if params[:template_id]
        template = CloudComputing::Template.find(params[:template_id])
        if template.initial_requests?
          item = @request.new_left_items.new(template: template)

          template.editable_resources.each do |r|
            item.resource_items.new(resource: r, value: r.value)
          end
        end
      end
    end

    def update_created_request
      if @request.update(request_params)
        @request.left_items.each do |item|
          item.resource_items.each do |r_i|
            r_i.destroy if r_i.item.template_id != r_i.resource.template_id
          end
        end
        redirect_to created_request_requests_path, notice: t('.updated_successfully')
      else
        render :edit_created_request
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
      left_items_attributes = [:id, :amount, :_destroy, :template_id,
        from_links_attributes: [:id, :_destroy, :from_id, :amount, :to_item_id],
        from_items_attributes: [:id, :to_link_amount, :_destroy,
          resource_items_attributes: %i[id resource_id value] ],
        resource_items_attributes: %i[id resource_id value]]

      params.require(:request).permit(:for_id, :for_type, :comment, :finish_date,
                              old_left_items_attributes: left_items_attributes,
                              new_left_items_attributes: left_items_attributes)
    end
  end
end
