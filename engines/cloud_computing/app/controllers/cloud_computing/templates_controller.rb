module CloudComputing
  class TemplatesController < ApplicationController

    def index
      respond_to do |format|
        format.json do
          @templates = Template.for_users.where(template_kind: TemplateKind.find(params[:template_kind_id])
                                                           .self_and_descendants)
                       .includes(resources: :resource_kind)
          per = params[:per] || 20
          pages = (@templates.count.to_f / per).ceil
          page = (params[:page] || 1).to_i
          page = page > pages ? pages : page

          render json: { data: @templates.page(page).per(per), pages: pages, page: page }

        end
        format.html do
          params[:q] ||= {
            template_kind_and_descendants: [TemplateKind.virtual_machine_cloud_class&.id.to_s]
          }
          @search = CloudComputing::Template.for_users.search(params[:q])
          @templates = @search.result(distinct: true)
                          .order_by_name
                          .page(params[:page])
                          .per(params[:per])
          @items = Item.with_user_requests(current_user.id)
                               .where(cloud_computing_requests: {status: 'created'})
                               .where(template_id: @templates.map(&:id))
                               .group('template_id')
                               .count('id')
        end
      end

    end

    def show
      @template = CloudComputing::Template.for_users.find(params[:id])
    end

    def edit
      @template = CloudComputing::Template.for_users.find(params[:id])
      @positions = @template.positions.with_user_requests(current_user)
    end

    def update
      authorize! :create, CloudComputing::Request
      @template = CloudComputing::Template.for_users.find(params[:id])
      @template.assign_attributes(position_params)
      @template.assign_atributes_for_positions(current_user)
      if @template.save
        redirect_to @template, flash: { info: t('.updated_successfully') }
      else
        render :show, flash: { info: t('.errors') }
      end
    end

    def position_params
      params.require(:template).permit(positions_attributes: [:amount, :id,
        :_destroy, resource_items_attributes: %i[id resource_id value]])
    end
  end
end
