module Core
  class EmploymentsController < Core::ApplicationController
    before_action :require_login
    before_action :filter_blocked_users

    def new
      @employment = current_user.employments.build do |employment|
        hash = employment_params
        employment.organization = Organization.find(hash[:organization_id]) if hash && hash[:organization_id].present?
      end
      @employment.build_default_positions
    end

    def create
      @employment = current_user.employments.build(employment_params)
      @employment.user_crud_context = true
      if @employment.save
        redirect_to main_app.profile_path
      else
        @employment.build_default_positions
        render :new
      end
    end

    def show
      @employment = current_user.employments.find(params[:id])
      @employment.build_default_positions
    end

    def update
      @employment = current_user.employments.find(params[:id])
      @employment.user_crud_context = true
      if @employment.update(employment_params)
        @employment.save
        redirect_to main_app.profile_path
      else
        @employment.build_default_positions
        render :show
      end
    end

    def destroy
      @employment = current_user.employments.find(params[:id])
      @employment.deactivate!
      @employment.save
      redirect_to main_app.profile_path
    end

    private

    def employment_params
      if params[:employment].present?
        params.require(:employment).permit(:organization_id,
                                           :organization_department_id,
                                           :organization_department_name,
                                           :primary,
                                           positions_attributes: %i[id name value field_id
                                                                    employment_position_name_id])
      else
        {}
      end
    end
  end
end
