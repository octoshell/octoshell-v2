module Core
  class Admin::OrganizationsController < Admin::ApplicationController
    layout "layouts/core/admin"
    def index
      respond_to do |format|
        format.html do
          provide_cities_hash
          @search = Organization.search(params[:q])
          search_result = @search.result(distinct: true).includes(:kind, :city, :country).order(id: :desc)
          @organizations = search_result.page(params[:page])
          @projects_count = Project.group(:organization_id)
                                   .where(organization_id: @organizations
                                   .to_a.map(&:id)).count
          @users_count = Employment.group(:organization_id).joins_active_users
                                   .where(state: 'active')
                                   .where(organization_id: @organizations
                                     .to_a.map(&:id)).count
        end
        format.json do
          @organizations = Organization.finder(params[:q])
          @current_organizations = @organizations.page(params[:page])
                                                 .per(params[:per])
                                                 .map(&:full_json)
          render json: { records: @current_organizations, total: @organizations.count}
        end
      end
    end

    def index_for_organization
      respond_to do |format|
        format.json do
          @departments = Organization.find(params[:id]).departments
          @array = @departments.map { |d| { id: d.id, text: d.name } }
          render json: @array
        end
      end
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)
      if params[:city_id]
        @organization.city_id=params[:city_id]
      end
      if @organization.save
        if @organization.kind.departments_required?
          redirect_to [:admin, :edit, @organization], notice: t("flash.you_have_to_fill_departments")
        else
          @organization.departments.create!(name: @organization.short_name)
          redirect_to [:admin, @organization]
        end
      else
        render :new
      end
    end

    def show
      @organization = Organization.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @organization }
      end
    end

    def edit
      @organization = Organization.find(params[:id])
    end

    def update
      @organization = Organization.find(params[:id])
      if @organization.update_attributes(organization_params)
        @organization.save
        redirect_to [:admin, @organization]
      else
        render :edit
      end
    end

    def destroy
      @organization = Organization.find(params[:id])
      if @organization.destroy_allowed?
        @organization.employments.destroy_all
        @organization.destroy
        redirect_to admin_organizations_path
      else
        redirect_to [:admin, @organization]
      end
    end



    def merge_edit
      provide_cities_hash
      @kinds = OrganizationKind.all.to_a.map { |k| { id: k.id, text: k.to_s } }
      @id = params[:id]
      @text = params[:text]
      # @organization = Organization.includes(:departments).find(params[:id])
      # @departments_names = @organization.departments.map { |d| { id: d.id, text: d.name } }
      @merge_types_options = %w[merge_with_organization merge_with_existing_department
                                merge_with_new_department]
      @merge_types_labels = @merge_types_options.map { |o| t ".#{o}" }
      @source_merge_type_options = %w[merge_organization merge_department]
      @to_types_options = %w[create_organization merge]
      @to_types_labels = @to_types_options.map { |o| t ".#{o}" }
      @source_merge_type_labels = @source_merge_type_options.map { |o| t ".#{o}" }
    end

    def merge_update
      load_source_objects
      error = if params[:to][:to_type] == 'create_organization'
                create_organization
              else
                load_to_objects_and_merge
              end
      if error
        readable_error = case error
                         when 'forbidden'
                           t '.forbidden'
                         when 'same_object'
                           t '.same_object'
                         when 'stale_organization_id'
                           to_org_name = Organization.find(@to_org_id).name
                           to_dep_name = OrganizationDepartment.find(params[:to][:department_id]).name
                           t('.stale_organization_id', dep_name: to_dep_name, org_name: to_org_name) +
                            t('.update')
                         else
                           error
                         end
        render status: 400, json: { message: readable_error }
      else
        organization_id = params[:source][:organization_id]
        @org = Organization.includes(:departments).find_by(id: organization_id)
        if @org
          @array = @org.departments.map { |d| { id: d.id, text: d.name } }
          render status: 200, json: @array
        else
          render status: 200, json: { reload: true }
        end
      end
    rescue ActiveRecord::RecordNotFound, MergeError => e
      render status: 400, json: { message: e.message + t('.update') }

    end

    private

    def source_object
      if @department
        @department
      else
        @organization
      end
    end

    def create_organization
      @res, @error = source_object.create_organization create_organization_params
      @error
    end

    def load_source_objects
      @organization = Organization.find params[:source][:organization_id]
      @source_merge_type = params[:source][:merge_type]
      if @source_merge_type == 'merge_department'
        @department = OrganizationDepartment.find params[:source][:department_id]
        if @department.organization != @organization
          raise MergeError, t('.stale_organization_id_source',
                              dep_name: @department.name,
                              org_name: @organization.name)

        end
      elsif @source_merge_type != 'merge_organization'
        raise ArgumentError, 'source_merge_type is invalid'
      end
    end

    def load_to_objects_and_merge
      @to_org_id = params[:to][:organization_id].to_i
      Organization.find @to_org_id
      @to_merge_type = params[:to][:merge_type]
      @res, @error = case @to_merge_type
                     when 'merge_with_organization'
                       source_object.merge_with_organization @to_org_id
                     when 'merge_with_new_department'
                       source_object.merge_with_new_department @to_org_id, params[:to][:department_name]
                     when 'merge_with_existing_department'
                       source_object.merge_with_existing_department(@to_org_id, params[:to][:department_id].to_i)
                     end
      if @res.instance_of?(DepartmentMerger)
        @link = view_context.link_to t('.here'), edit_admin_prepare_merge_path(@res).to_s
        @error = t('.not_auto', link: @link)
      end
      @error
    end

    def create_organization_params
      params[:to].require(:create_organization).permit(:checked, :name, :abbreviation, :city_id, :country_id, :kind_id)
    end

    def organization_params
      params.require(:organization).permit(:checked, :name, :abbreviation, :city_id, :country_id, :kind_id, :id,
                                           :_destroy, departments_attributes: [ :name, :_destroy, :id, :checked], city_attributes: [:id])
    end
  end
end
