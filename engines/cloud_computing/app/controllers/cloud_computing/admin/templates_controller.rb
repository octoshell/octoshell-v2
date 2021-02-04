require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class TemplatesController < CloudComputing::Admin::ApplicationController
    def index
      @search = CloudComputing::Template.search(params[:q])
      @templates = @search.result(distinct: true)
                      .order_by_name
                      .page(params[:page])
                      .per(params[:per])
      respond_to do |format|
        format.html
        format.json do
          render json: { records: @templates.page(params[:page])
                                                 .per(params[:per]),
                         total: @templates.count }
        end
      end
    end

    def show
      @template = CloudComputing::Template.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @template }
      end
    end

    def new
      @template = CloudComputing::Template.new
      fill_resources
    end

    def create
      @template = CloudComputing::Template.new(template_params)
      fill_resources
      @template.resources.each do |resource|
        if deleted_kinds.include? resource.resource_kind_id
          resource.mark_for_destruction
        end
      end
      if @template.save
        redirect_to [:admin, @template]
      else
        render :new
      end
    end

    def edit
      @template = CloudComputing::Template.find(params[:id])
      fill_resources
    end

    def update
      @template = CloudComputing::Template.find(params[:id])
      if @template.update(template_params)
        redirect_to [:admin, @template]
      else
        fill_resources
        render :edit
      end
    end

    def destroy
      @template = CloudComputing::Template.find(params[:id])
      @template.destroy!
      redirect_to admin_templates_path
    end

    private

    def fill_resources
      @template.fill_resources
    end

    def deleted_kinds
      template_params[:resources_attributes].values.select do |hash|
        hash[:_destroy] == '1'
      end.map do |hash|
        hash[:resource_kind_id].to_i
      end
    end

    def template_params
      params.require(:template).permit(*CloudComputing::Template
                                           .locale_columns(:name, :description),
                                          :identity,
                                          :template_kind_id,
                                          :new_requests,
                                          resources_attributes: %i[id value
                                          resource_kind_id min max editable
                                          _destroy])
    end
  end
end
